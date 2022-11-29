#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
TRIES=0
SECRET_NUMBER=$((1 + $RANDOM % 1000))
echo $SECRET_NUMBER

MAIN(){
  echo "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME' ")

  if [[ -z $USER_ID ]]
  then
    INSERT_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    echo -e "\nGuess the secret number between 1 and 1000:"
    
    NUMBER_GUESS

    INSERT_GAME=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $TRIES)")
  else
    QUERY=$($PSQL "SELECT username, count(guesses), min(guesses) FROM users INNER JOIN games USING (user_id) WHERE user_id=$USER_ID GROUP BY user_id")
    echo $QUERY | while IFS="|" read USERNAME N_GAMES BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $N_GAMES games, and your best game took $BEST_GAME guesses."
    done
      echo -e "\nGuess the secret number between 1 and 1000:"
      NUMBER_GUESS
      INSERT_GAME=$($PSQL "INSERT INTO games (user_id, guesses) VALUES ($USER_ID, $TRIES)")
  fi
}

NUMBER_GUESS(){
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    NUMBER_GUESS
  else
    TRIES=$(( TRIES + 1 ))
    if [[ $SECRET_NUMBER -lt $GUESS ]]
    then
      echo "It's lower than that, guess again:"
      NUMBER_GUESS
    elif [[ $SECRET_NUMBER -gt $GUESS ]]
    then 
      echo "It's higher than that, guess again:"
      NUMBER_GUESS
    else
      echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  fi
}

MAIN




