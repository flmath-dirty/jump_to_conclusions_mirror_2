PROJ_NAME =   -sname jtc
DEPS = ranch cowlib cowboy jsx

# debug info added for edts nodes to function
# debug macro also included in file, to activate run
# make ERLC='erlc +debug_info -DTEST' web_server
export ERLC = erlc +debug_info

ERL_CALL = erl_call
EC_SERV = $(ERL_CALL)  $(PROJ_NAME) 

ERL = erl
ERL_SERV = $(ERL) $(PROJ_NAME) $(ALL_PATHS) -detached

PA_PATHS =	-pa $(JSX_ROOT)/ebin	\
		-pa $(COWLIB_ROOT)/ebin	\
		-pa $(RANCH_ROOT)/ebin	\
		-pa $(COWBOY_ROOT)/ebin	\
		-pa ebin 
ALL_PATHS = -I $(COWLIB_ROOT)/include \
		$(PA_PATHS)

JSX_ROOT = deps/jsx
COWLIB_ROOT = deps/cowlib
RANCH_ROOT = deps/ranch
COWBOY_ROOT = deps/cowboy

all	: jsx cowlib ranch cowboy web_server

web_server : 
	mkdir -p ebin/
	mkdir -p tmp/
	mkdir -p testlogs/
	cp  src/web_server.app.src ebin/web_server.app
	$(ERLC) -o ebin \
		-I $(COWLIB_ROOT)/include \
		-pa $(COWLIB_ROOT)/ebin  \
		-pa $(RANCH_ROOT)/ebin   \
		-pa $(COWBOY_ROOT)/ebin  \
		 src/*.erl
jsx	:
	mkdir -p $(JSX_ROOT)/ebin/
	cp $(JSX_ROOT)/src/jsx.app.src $(JSX_ROOT)/ebin/jsx.app
	$(ERLC)  -o $(JSX_ROOT)/ebin deps/jsx/src/*.erl

cowlib	:
	mkdir -p $(COWLIB_ROOT)/ebin/
	cp $(COWLIB_ROOT)/src/cowlib.app.src $(COWLIB_ROOT)/ebin/cowlib.app
	$(ERLC)  -I $(COWLIB_ROOT)/include -o $(COWLIB_ROOT)/ebin $(COWLIB_ROOT)/src/*.erl
ranch	:
	mkdir -p $(RANCH_ROOT)/ebin/
	cp $(RANCH_ROOT)/src/ranch.app.src $(RANCH_ROOT)/ebin/ranch.app
	$(ERLC)  -o  $(RANCH_ROOT)/ebin  $(RANCH_ROOT)/src/*.erl
cowboy	:
	$(ERLC) -o $(COWBOY_ROOT)/ebin -I $(COWLIB_ROOT)/include \
		-pa $(COWLIB_ROOT)/ebin  \
		 $(COWBOY_ROOT)/src/*.erl



clean	:
	rm -rf $(COWLIB_ROOT)/ebin/*beam
	rm -rf $(RANCH_ROOT)/ebin/*beam
	rm -rf $(COWBOY_ROOT)/ebin/*beam
	rm -rf $(JSX_ROOT)/ebin/*beam
	rm -rf ebin/*
	rm -f web_server.script web_server.boot web_server.rel

stop	:
	$(EC_SERV)  -a 'init stop []' -c .erlang.cookie -s
kill_node	:
	ps aux | grep jtc | grep -v grep | head -n 1 \
	| awk '{print $$2}' | xargs -r kill
kill_edts	:
	ps aux | grep edts_conclusions | grep -v grep | head -n 1 \
	| awk '{print $$2}' | xargs -r kill
script		:
	./make_script 
# kill_node
#	epmd -kill
#	$(ERL_SERV) -setcookie .erlang.cookie  -run systools make_script "web_server" 


start	:
	$(ERL) $(ALL_PATHS) -boot web_server -config sys

