-module(ebank_srv).
-behaviour(gen_server).


%-define(SERVER, {local, ?MODULE}).
-define(SERVER, {global, ?MODULE}).


%% ------------------------------------------------------------------
%% API Function Exports
%% ------------------------------------------------------------------

%% API
-export([
    start_link/0,
    create_account/1,
    deposit/2,
    withdraw/2,
    balance/1,
    delete_account/1
    ]).

%% ------------------------------------------------------------------
%% gen_server Function Exports
%% ------------------------------------------------------------------

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% @doc unit in which account balance is held
-type currency() :: number().

%%====================================================================
%% API
%%====================================================================

%% @doc Starts the server
-spec start_link() -> {ok,pid()} | ignore | {error,{already_started,pid()}|term()}.
start_link() ->
  gen_server:start_link(?SERVER, ?MODULE, [], []).

%% @doc Creates a bank account for the person with name Name
-spec create_account(Name::string()) -> ok.
create_account(Name) ->
  gen_server:cast(?SERVER, {create, Name}).

%% @doc deletes the account with the name Name.
-spec delete_account(Name::string()) -> ok.
delete_account(Name) ->
  gen_server:cast(?SERVER, {delete, Name}).

%% @doc Deposits Amount into Name's account. Returns the
%% balance if successful, otherwise returns an error and reason.
-spec deposit(Name::string(), Amount::currency()) -> {ok, currency()} | {error,term()}.
deposit(Name, Amount) ->
  gen_server:call(?SERVER, {deposit, Name, Amount}).

%% @doc Withdraws Amount from Name's account.
-spec withdraw(Name::string(), Amount::currency()) -> {ok, currency()}|{error,term()}.
withdraw(Name, Amount) ->
  gen_server:call(?SERVER, {withdraw, Name, Amount}).

%% @doc Returns balance for Name's acount 
-spec balance(Name::string()) -> {ok, currency()}|{error,term()}.
balance(Name) ->
  gen_server:call(?SERVER, {balance, Name}).

%%====================================================================
%% gen_server callbacks
%%====================================================================

%%--------------------------------------------------------------------
%% Function: init(Args) -> {ok, State} |
%%                         {ok, State, Timeout} |
%%                         ignore               |
%%                         {stop, Reason}
%% Description: Initiates the server
%%--------------------------------------------------------------------
-spec init([]) -> {ok, term()}.
init([]) ->
  {ok, dict:new()}.

%%--------------------------------------------------------------------
%% Function: %% handle_call(Request, From, State) -> {reply, Reply, State} |
%%                                      {reply, Reply, State, Timeout} |
%%                                      {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, Reply, State} |
%%                                      {stop, Reason, State}
%% Description: Handling call messages
%%--------------------------------------------------------------------
handle_call({deposit, Name, Amount}, _From, State) ->
  case dict:find(Name, State) of
    {ok, Value} ->
      NewBalance = Value + Amount,
      Response = {ok, NewBalance},
      NewState = dict:store(Name, NewBalance, State),
      {reply, Response, NewState};
    error ->
      {reply, {error, account_does_not_exist}, State}
  end;
handle_call({withdraw, Name, Amount}, _From, State) ->
  case dict:find(Name, State) of
    {ok, Value} when Value < Amount ->
      {reply, {error, not_enough_funds}, State};
    {ok, Value} ->
      NewBalance = Value - Amount,
      NewState = dict:store(Name, NewBalance, State),
      {reply, {ok, NewBalance}, NewState};
    error ->
      {reply, {error, account_does_not_exist}, State}
  end;
handle_call({balance, Name}, _From, State) ->
  case dict:find(Name, State) of
    {ok, Value} ->
      {reply, {ok, Value}, State};
    error ->
      {reply, {error, account_does_not_exist}, State}
  end;

handle_call(_Request, _From, State) ->
  Reply = ok,
  {reply, Reply, State}.

%%--------------------------------------------------------------------
%% Function: handle_cast(Msg, State) -> {noreply, State} |
%%                                      {noreply, State, Timeout} |
%%                                      {stop, Reason, State}
%% Description: Handling cast messages
%%--------------------------------------------------------------------
handle_cast({create, Name}, State) ->
  {noreply, dict:store(Name, 0, State)};
handle_cast({delete, Name}, State) ->
  {noreply, dict:erase(Name, State)};
handle_cast(_Msg, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% Function: handle_info(Info, State) -> {noreply, State} |
%%                                       {noreply, State, Timeout} |
%%                                       {stop, Reason, State}
%% Description: Handling all non call/cast messages
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
  {noreply, State}.

%%--------------------------------------------------------------------
%% Function: terminate(Reason, State) -> void()
%% Description: This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any necessary
%% cleaning up. When it returns, the gen_server terminates with Reason.
%% The return value is ignored.
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
  ok.

%%--------------------------------------------------------------------
%% Func: code_change(OldVsn, State, Extra) -> {ok, NewState}
%% Description: Convert process state when code is changed
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

%%--------------------------------------------------------------------
%%% Internal functions
%%--------------------------------------------------------------------

