#!/bin/bash

# Define the function
my_function() {
    local input1="$1"
    local input2="$2"
    
    # Perform some operations
    local output1="Output 1"
    local output2="Output 2"
    
    # Assign the output parameters
    eval "$3='$output1'"
    eval "$4='$output2'"
}

# Call the function and pass input parameters
input_param1="Input 1"
input_param2="Input 2"
my_function "$input_param1" "$input_param2" output_param1 output_param2

# Access the output parameters
echo "Output 1: $output_param1"
echo "Output 2: $output_param2"

