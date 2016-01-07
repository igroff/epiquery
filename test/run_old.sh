#! /usr/bin/env bash
source ../bin/setup-environment
export EPIQUERY_SERVER=localhost
TEST_URL=http://${EPIQUERY_SERVER}:${EPIQUERY_HTTP_PORT-9090}
echo Using ${TEST_URL} for testing
mkdir -p tmp/
function run_test() {
  PATH_NAME=`echo $1 | sed -e s[?.*[[g`
  curl -X ${METHOD-GET} -A 'curl/7.30.0' -s "${TEST_URL}/test/$1" ${@:2} > tmp/$PATH_NAME.result
  diff data/$PATH_NAME.expected tmp/$PATH_NAME.result
  DIFF_RESULT=$?
  printf "Test %s " ${PATH_NAME}
  if [ $DIFF_RESULT -eq 0 ]; then
    echo "success"
  else
    echo "failed"
  fi
}
function do_post(){
  PATH_NAME=`echo $1 | sed -e s[?.*[[g`
  curl -X POST -A 'curl/7.30.0' -s "${TEST_URL}/test/$1" ${@:2} > tmp/$PATH_NAME.result
  diff data/$PATH_NAME.expected tmp/$PATH_NAME.result
  DIFF_RESULT=$?
  printf "Test %s " ${PATH_NAME}
  if [ $DIFF_RESULT -eq 0 ]; then
    echo "success"
  else
    echo "failed"
  fi
}
function run_dynamic_test(){
  # development query tests
  TEST_NAME=$1
  TEMPLATE=$2
  curl -s ${TEST_URL}/$1 -A 'curl/7.30.0' --data-urlencode "__template=${TEMPLATE}" > tmp/${TEST_NAME}.result "$@"

  diff data/${TEST_NAME}.expected tmp/${TEST_NAME}.result
  DIFF_RESULT=$?
  printf "Test %s " $TEST_NAME
  if [ $DIFF_RESULT -eq 0 ]; then
    echo "success"
  else
    echo "failed"
  fi
}

run_test error
run_test sysobjects
run_test 'hello.mustache?name=Ian'
run_test echo.error
run_test no.such.file
run_test 1000_rows
run_test multiple_rows_multiple_results
run_test multiple_rows_multiple_results.mustache
run_test multiple_rows_multiple_results.dot
run_test multiple_rows
run_test multiple_result.mustache
run_test multiple_result_one_empty
do_post 'echo.dot?message=pants&dog=blue'
do_post prepare_a_statement
do_post 'prepare_a_statement_with_param.mustache?id=1'
run_test do_stuff_but_return_no_results
run_test mysql_simple_select
# GETs are going to be read uncommitted
run_test mysql_txi_level 
do_post app_json_mysql_hello.mustache --data-binary '{"name":"ian"}' -H 'Content-Type:application/json'
run_test array_in_context.mustache --data-binary '{"items":[{"name":"one"},{"name":"two"}]}' -H 'Content-Type:application/json'

# want to make sure we get something simliar with and without a specific connection
do_post mysql_multiple_row_select
do_post mysql_multiple_row_select -H 'X-DB-CONNECTION: {"host":"localhost", "user":"epiquery"}'


run_dynamic_test dynamic1 'select 1 [column]'
run_dynamic_test dynamic2 "select 'Hello, '+'{{name}}' [message]" --data-urlencode 'name=ian'
run_dynamic_test mysql_login_with_header 'select user();' -H 'X-DB-CONNECTION: {"host":"localhost", "user":"epiquery"}'
run_dynamic_test mysql_login_as_configd 'select user()'
run_dynamic_test sql_server_login_with_header 'select suser_name()' -H 'X-DB-CONNECTION: {"userName":"hulk", "password":"smash1", "server":"glgdb503a.glgint.net"}'
run_dynamic_test sql_server_login_as_configd 'select suser_name()' 
