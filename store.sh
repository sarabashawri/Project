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


# Function to display previous bookings
display_bookings() {
    echo "Previous bookings for $first_name:"
    grep "$first_name" bookings.txt || echo "No bookings found."
}

# Function to rent a car
rent_car() {
    echo "Select car type:"
    echo "1. Family car"
    echo "2. Sport car"
    echo "3. Motorcycle"
    echo "4. Truck"
    echo "5. Luxury car"
    while true; do
        read -p "Enter choice (1-5): " car_type_choice
        case $car_type_choice in
            1) car_type="Family"; break;;
            2) car_type="Sport"; break;;
            3) car_type="Motorcycle"; break;;
            4) car_type="Truck"; break;;
            5) car_type="Luxury"; break;;
            *) echo "Invalid choice. Please enter a number between 1 and 5.";;
        esac
    done

    echo "Select your budget:"
    echo "1. 80-120"
    echo "2. 120-150"
    echo "3. 150-250"
    echo "4. 250-600"
    echo "5. 600-1200"
    while true; do
        read -p "Enter choice (1-5): " budget_choice
        case $budget_choice in
            1) min_budget=80; max_budget=120; break;;
            2) min_budget=120; max_budget=150; break;;
            3) min_budget=150; max_budget=250; break;;
            4) min_budget=250; max_budget=600; break;;
            5) min_budget=600; max_budget=1200; break;;
            *) echo "Invalid choice. Please enter a number between 1 and 5.";;
        esac
    done

    echo "Available cars in $car_type category with budget $min_budget-$max_budget:"
    echo "--------------------------------------------------------------------------"
    echo "# Car Category | Car Type | Car Model | Plate Number | Color | Price"
    echo "--------------------------------------------------------------------------"
    available_cars=$(awk -F' \\| ' -v type="$car_type" -v min="$min_budget" -v max="$max_budget" '
    $1 == type && $6 >= min && $6 <= max { print $0 }' cars.txt)
    
    if [ -z "$available_cars" ]; then
        echo "No available cars match your criteria."
        return 1
    fi

    echo "$available_cars" | while IFS= read -r line; do
        echo "$line"
        echo "--------------------------------------------------------------------------"
    done

    while true; do
        read -p "Enter the plate number of the car you want to rent: " plate_number
        if grep -q "| $plate_number |" <<< "$available_cars"; then
            break
        else
            echo "Invalid plate number."
        fi
    done

    while true; do
        read -p "Enter rental start date (YYYY/MM/DD): " start_date
        if [[ "$start_date" =~ ^[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
            break
        else
            echo "Invalid date format."
        fi
    done

    while true; do
        read -p "Enter rental end date (YYYY/MM/DD): " end_date
        if [[ "$end_date" =~ ^[0-9]{4}/[0-9]{2}/[0-9]{2}$ ]]; then
            break
        else
            echo "Invalid date format."
        fi
    done

    # Convert dates to the format YYYY-MM-DD for compatibility with the date command
    start_date_formatted=$(date -d "${start_date//\//-}" +%Y-%m-%d)
    end_date_formatted=$(date -d "${end_date//\//-}" +%Y-%m-%d)

    # Calculate the difference between dates in days
    start_date_seconds=$(date -d "$start_date_formatted" +%s)
    end_date_seconds=$(date -d "$end_date_formatted" +%s)
    rental_days=$(( (end_date_seconds - start_date_seconds) / 86400 ))

    if [ "$rental_days" -lt 0 ]; then
        echo "End date cannot be before start date."
        return 1
    fi

    echo "Rental duration: $rental_days days"

    # Retrieve the selected car information based on the plate number
    selected_car=$(grep "$plate_number" <<< "$available_cars")
    daily_rate=$(echo "$selected_car" | awk -F' \\| ' '{print $6}')
    rental_price=$(echo "$rental_days * $daily_rate" | bc)

    # Record the rental in bookings.txt
    echo "Rental recorded: $first_name $plate_number $start_date $end_date" >> bookings.txt
    echo "Total rental price: $rental_price"
    echo "Please return the car by $end_date."
}

