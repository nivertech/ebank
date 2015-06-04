-module(ebank).

-export([
	start/0, 
	stop/0, 
	create_account/1, 
	delete_account/1, 
	deposit/2, 
	withdraw/2, 
	balance/1
	]).

-define(APPLICATION, ebank).

start() -> 
    application:start(?APPLICATION).

stop() -> 
    application:stop(?APPLICATION).

create_account(Name) -> 
    ebank_srv:create_account(Name).

delete_account(Name) ->
    ebank_srv:delete_account(Name).

deposit(Name, Amount) -> 
    ebank_srv:deposit(Name, Amount).

withdraw(Name, Amount) ->
    ebank_srv:withdraw(Name, Amount).

balance(Name) ->
    ebank_srv:balance(Name).
