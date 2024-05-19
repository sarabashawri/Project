#!/bin/bash

# Variable to store the user's first name
first_name=""

# Function to display the menu
display_menu() {
    echo "Main Menu:"
    echo "1. Rent a car"
    echo "2. Return a car"
    echo "3. View previous bookings"
    echo "4. Exit"
    echo "------------------"
    echo "Enter your choice (1-4): "
}

# Function to validate name
validate_name() {
    if [[ ! "$1" =~ ^[A-Za-z]+$ ]]; then
        echo "Invalid name format. Please enter alphabetic characters only."
        return 1
    fi
    return 0
}

# Function to validate age
validate_age() {
    if ! [[ "$1" =~ ^[0-9]{2}$ ]]; then
        echo "Age must be a two-digit number."
        return 1
    fi
    if [ "$1" -lt 21 ]; then
        echo "Sorry, you must be at least 21 years old to rent a car."
        exit 1
    fi
    return 0
}

# Function to validate phone number format
validate_phone() {
    if [[ ! "$1" =~ ^05[0-9]{8}$ ]]; then
        echo "Invalid phone number format."
        return 1
    fi
    return 0
}

# Function to validate driving license format
validate_license() {
    if [[ ! "$1" =~ ^[A-Z]{2}[0-9]{6}$ ]]; then
        echo "Invalid driving license format."
        return 1
    fi
    return 0
}

# Function to handle new customer registration
register_new_customer() {
    while true; do
        while true; do
            read -p "First name: " first_name
            if validate_name "$first_name"; then
                break
            fi
        done
        
        while true; do
            read -p "Last name: " last_name
            if validate_name "$last_name"; then
                break
            fi
        done
        
        while true; do
            read -p "Age (must be a two-digit number): " age
            if validate_age "$age"; then
                break
            fi
        done
        
        while true; do
            read -p "Phone number (starting with 05XXXXXXXXX): " phone_number
            if validate_phone "$phone_number"; then
                break
            fi
        done
        
        while true; do
            read -p "Driving license (2 letters followed by 6 digits): " driving_license
            if validate_license "$driving_license"; then
                break
            fi
        done
        
        echo "$first_name $last_name $age $phone_number $driving_license" >> users.txt
        echo "Registration successful. Welcome, $first_name!"
        break
    done
}

# Function to handle returning customer login
returning_customer_login() {
    while true; do
        read -p "Welcome back! Please enter your first name: " first_name
        read -p "Last name: " last_name
        if grep -q "$first_name $last_name" users.txt; then
            echo "Welcome back, $first_name!"
            break
        else
            echo "No such user found. Please register first."
            register_new_customer
            break
        fi
    done
}
