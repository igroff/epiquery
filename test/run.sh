#! /usr/bin/env bash
TEST_URL=http://localhost:${EPIQUERY_HTTP_PORT-9090}
echo Using ${TEST_URL} for testing
function run_test() {
  PATH_NAME=`echo $1 | sed -e s[?.*[[g`
  curl -s "${TEST_URL}/test/$1" "${@:1}" > tmp/$PATH_NAME.result 
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
  curl -s ${TEST_URL}  --data-urlencode "__template=${TEMPLATE}" > tmp/${TEST_NAME}.result "$@"

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
run_test 'echo.dot?message=pants&dog=blue'
run_test prepare_a_statement
run_test 'prepare_a_statement_with_param.mustache?id=1'
run_test do_stuff_but_return_no_results
run_test array_in_context.mustache --data-binary '{"items":[{"name": "one"}, {"name": "two"}]}' -H 'Content-Type: application/json'

run_dynamic_test dynamic1 'select 1 [column]'
run_dynamic_test dynamic2 "select 'Hello, '+'{{name}}' [message]" --data-urlencode 'name=ian'
