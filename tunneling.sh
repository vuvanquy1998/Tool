#!/usr/bin/env bash

export SSH="ssh -o ServerAliveInterval=3600 -o ServerAliveCountMax=10"
export SBASE_HOST="sbase-dev-main"
export SBASE_PORT=16889
export SBASE_STAGING_HOST="sbase-stag-main"



get_env(){
    host=localhost
	sbase_host=$SBASE_HOST
    case $1 in
        ""|dev)
            host=localhost
        	;;
        staging|stag)
        	host=10.56.2.213
			sbase_host=$SBASE_STAGING_HOST
        	;;
        *)
        	echo "require enviroment error"f
        	exit
			;;
	esac
}

kill_connect_ssh_in_port(){

    # kill connect ssh
    ps -ef | grep ssh | grep -v -e grep -e root | grep $SBASE_HOST | grep $port_connect:localhost:$port_connect | awk '{print "sudo kill -9", $2}' | sh
    
    ps -ef | grep ssh | grep -v -e grep -e root | grep $SBASE_HOST | grep $port_connect:192.168.113.13:$port_connect | awk '{print "sudo kill -9", $2}' | sh

    ps -ef | grep ssh | grep -v -e grep -e root | grep $SBASE_STAGING_HOST | grep $port_connect:10.56.2.213:$port_connect | awk '{print "sudo kill -9", $2}' | sh


    #pid=$(lsof -ti tcp:$port_connect)
    #[ ! -z "$pid" ] && echo "kill process using port $port_connect" && echo $pid | xargs kill
}


sbase_start_mysql(){
    get_env $1
    port_connect=3306
    echo "mysql" $1
    connect
    #$SSH -fN -L 3306:$host:3306 -p $SBASE_PORT $sbase_host
}

sbase_start_mongo(){
    host=192.168.113.13
	sbase_host=$SBASE_HOST
    case $1 in
        ""|dev)
            host=192.168.113.13
        	;;
        staging|stag)
        	host=10.56.2.213
			sbase_host=$SBASE_STAGING_HOST
        	;;
        *)
        	echo "require enviroment error"
        	exit
			;;
	esac



    port_connect=27017
    echo "mongodb" $1

    connect
    #$SSH -fN -L 27017:localhost:27017 $SBASE_PORT $SBASE_HOST
}

sbase_start_redis(){
    get_env $1
    port_connect=6379
    case $1 in
        stag|staging)
            port_connect=6380
    esac
    echo "redis" $1 $port_connect
    connect
}

sbase_start_postgres(){
    get_env $1
    port_connect=5432
    echo "postgres" $1
    
    connect
}

sbase_start_elasticsearch(){
    get_env $1
    port_connect=9202
    echo "elasticsearch" $1
    
    connect
}

sbase_start_rabbit(){
    get_env $1
    port_connect=5672
    echo "rabbitmq" $1
    
    connect
}

connect(){
    kill_connect_ssh_in_port
    $SSH -fN -L $port_connect:$host:$port_connect -p $SBASE_PORT $sbase_host
}

sbase_start_db_tunneling() {
    clear
    echo "tunnel dev"

    # mysql
    sbase_start_mysql dev
    
    #rabbit
    #sbase_start_rabbit dev

    # elasticsearch
    sbase_start_elasticsearch dev
    
    # redis
    sbase_start_redis dev
    
    #postgres
    sbase_start_postgres dev
    
    #Mongodb
    sbase_start_mongo dev

    #sleep 1

    sbase_start_rabbit dev	
    #clear

	echo "Done"
    
}



# staging


staging_start_db_tunneling() {
    clear
    echo "tunnel staging"
    # mysql
    sbase_start_mysql stag
    
    #Mongodb
    sbase_start_mongo stag
    
    #redis
    sbase_start_redis stag
    
    # elasticsearch
    sbase_start_elasticsearch stag
    
    #Cassandra
    # echo "Cassandra"
    # $SSH -fN -L 9042:10.56.2.213:9042 -p $SBASE_PORT $SBASE_STAGING_HOST
    
    #postgres
    sbase_start_postgres stag
    
    echo "DONE"
}



stop_tunneling() {
    echo "stop tunneling"
    killall ssh
}




usage="Usage: tunneling.sh (sbase_start_db|start_db|stop)"

if [ $# -le 0 ]; then
    echo $usage
    exit 1
fi

command=$1
env=$2
shift 2

case $command in
    (stop)
        stop_tunneling
        ;;
    (sbase_start_db)
        stop_tunneling
        sbase_start_db_tunneling
        ;;

    (staging_start_db)
        stop_tunneling
        staging_start_db_tunneling
        ;;
    (mysql)
        sbase_start_mysql $env
        ;;
    (mongodb)
        sbase_start_mongo $env
        ;;
    (redis)
        sbase_start_redis $env
        ;;
    (elasticsearch)
        sbase_start_elasticsearch $env
        ;;
    (rabbitmq)
        sbase_start_rabbit $env
        ;;
    (kill_process)
        kill_connect_ssh_in_port $command
        ;;
esac
