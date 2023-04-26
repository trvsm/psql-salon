#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

#salon title
echo -e "\n:<:<:< Travis' Barbershop >:>:>:"

MAIN(){
#welcome how can I help
if [[ -z $1 ]]
then
  echo -e "\nWelcome, how can I help you?\n"
else
  echo -e "\nPlease select a service by number:"
fi

#display a numbered list of services
SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
  if [[ $SERVICE_ID =~ ^[0-9] ]]
  then
    echo "$SERVICE_ID) $NAME"
  fi
done

#read service_id
read SERVICE_ID_SELECTED
#if a non-existent service picked display service list
VALIDATE_SERVICE=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")
if [[ -z $VALIDATE_SERVICE ]]
then
  #I could not find that service, how can I help?
  MAIN 1
fi

}
MAIN

echo -e "\nWhat is your phone number?"
#read phone number
read CUSTOMER_PHONE

#if no entry for phone number
PHONE_IN_DB=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $PHONE_IN_DB ]]
then
  #I don't have a record, what's your name
  echo "I don't have a record for that number, what's your name?"
  #read name
  read CUSTOMER_NAME
  #insert name & number to database
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
else
  #else get name from database
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
#what time would you like your <service>
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
#read time
read SERVICE_TIME

#insert into table
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

#I have put you down for a <service> at <time>, customer
echo -e "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."