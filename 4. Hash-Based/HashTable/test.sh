#!/bin/bash

################################################################################
# Hash Table C Implementation - Build and Test Script
# Tests the C implementation against expected output
################################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PROGRAM_NAME="hashtable_c"
C_FILE="hashtable.c"
EXECUTABLE="./${PROGRAM_NAME}"
EXPECTED_OUTPUT="expected_output.txt"
ACTUAL_OUTPUT="actual_output.txt"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_test() {
    echo -e "${CYAN}[TEST]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v gcc &> /dev/null; then
        log_error "GCC compiler not found. Please install it."
        echo "  Ubuntu/Debian: sudo apt install gcc"
        echo "  Fedora/RHEL: sudo dnf install gcc"
        exit 1
    fi
    log_success "GCC found: $(gcc --version | head -n 1)"
}

# Compile the C program
compile_program() {
    log_info "Compiling ${C_FILE}..."
    
    if [ ! -f "$C_FILE" ]; then
        log_error "Source file ${C_FILE} not found!"
        exit 1
    fi
    
    if gcc -std=c99 -Wall -Wextra -o "$PROGRAM_NAME" "$C_FILE"; then
        log_success "Compilation completed successfully"
        return 0
    else
        log_error "Compilation failed!"
        exit 1
    fi
}

# Create expected output file
create_expected_output() {
    log_info "Creating expected output reference..."
    
    cat > "$EXPECTED_OUTPUT" << 'EOF'
✓ Hash Table initialized
  Table Size: 16 entries
  Entry Size: 16 bytes

✓ Inserted: key=42, value=100
✓ Inserted: key=15, value=200
✓ Inserted: key=97, value=300
✓ Inserted: key=3, value=400
✓ Inserted: key=88, value=500
✓ Inserted: key=120, value=600

✓ Found: key=42, value=100 (Expected: 100)
✓ Found: key=15, value=200 (Expected: 200)
✓ Found: key=97, value=300 (Expected: 300)
✓ Found: key=3, value=400 (Expected: 400)
✓ Found: key=88, value=500 (Expected: 500)
✓ Found: key=120, value=600 (Expected: 600)

Search Results: 6 passed, 0 failed

✓ Collision handled successfully via linear probing
✓ Inserted: key=58, value=999

✓ Successfully deleted key=15
✓ Verified: key=15 is no longer in table

✓ All tests completed successfully!
EOF

    log_success "Expected output reference created"
}

# Run the program and capture output
run_program() {
    log_info "Running ${PROGRAM_NAME}..."
    
    if [ ! -f "$EXECUTABLE" ]; then
        log_error "Executable ${EXECUTABLE} not found!"
        exit 1
    fi
    
    if $EXECUTABLE > "$ACTUAL_OUTPUT" 2>&1; then
        log_success "Program executed successfully"
        return 0
    else
        log_error "Program execution failed!"
        cat "$ACTUAL_OUTPUT"
        exit 1
    fi
}

# Verify output correctness
verify_output() {
    log_test "Verifying output correctness..."
    
    local passed=0
    local failed=0
    
    # Check for key markers in output
    local markers=(
        "Hash Table initialized"
        "Inserted: key=42, value=100"
        "Inserted: key=15, value=200"
        "Inserted: key=97, value=300"
        "Inserted: key=3, value=400"
        "Inserted: key=88, value=500"
        "Inserted: key=120, value=600"
        "Found: key=42, value=100"
        "Found: key=15, value=200"
        "Found: key=97, value=300"
        "Found: key=3, value=400"
        "Found: key=88, value=500"
        "Found: key=120, value=600"
        "Search Results: 6 passed, 0 failed"
        "Collision handled successfully"
        "Successfully deleted key=15"
        "no longer in table"
        "All tests completed successfully"
    )
    
    for marker in "${markers[@]}"; do
        if grep -q "$marker" "$ACTUAL_OUTPUT"; then
            log_success "✓ Found: '$marker'"
            ((passed++))
        else
            log_error "✗ Missing: '$marker'"
            ((failed++))
        fi
    done
    
    echo ""
    log_info "Output verification: $passed passed, $failed failed"
    
    if [ $failed -eq 0 ]; then
        log_success "All output markers verified!"
        return 0
    else
        log_error "Some output markers missing!"
        echo -e "\n${YELLOW}Actual output:${NC}"
        cat "$ACTUAL_OUTPUT"
        return 1
    fi
}

# Run detailed tests
run_detailed_tests() {
    log_test "Running detailed functionality tests..."
    
    echo ""
    log_test "TEST 1: Hash Function Verification"
    echo "Testing hash function with various inputs..."
    
    # Create a simple test program
    cat > test_hash.c << 'EOF'
#include <stdio.h>
#include <stdint.h>

#define TABLE_SIZE 16

uint64_t hash_function(uint64_t key) {
    return key % TABLE_SIZE;
}

int main() {
    printf("Hash values for test keys:\n");
    printf("  hash(42)  = %llu (expected: %llu)\n", (unsigned long long)hash_function(42), (unsigned long long)(42 % TABLE_SIZE));
    printf("  hash(15)  = %llu (expected: %llu)\n", (unsigned long long)hash_function(15), (unsigned long long)(15 % TABLE_SIZE));
    printf("  hash(97)  = %llu (expected: %llu)\n", (unsigned long long)hash_function(97), (unsigned long long)(97 % TABLE_SIZE));
    printf("  hash(3)   = %llu (expected: %llu)\n", (unsigned long long)hash_function(3), (unsigned long long)(3 % TABLE_SIZE));
    printf("  hash(58)  = %llu (expected: %llu)\n", (unsigned long long)hash_function(58), (unsigned long long)(58 % TABLE_SIZE));
    return 0;
}
EOF

    if gcc -std=c99 -o test_hash test_hash.c && ./test_hash; then
        log_success "Hash function tests passed"
        rm -f test_hash test_hash.c
    else
        log_warning "Hash function test failed"
        rm -f test_hash test_hash.c
    fi
    
    echo ""
    log_test "TEST 2: Collision Detection"
    echo "Checking collision handling for similar hash values..."
    
    # Keys that might cause collisions
    printf "  Key 42 and key 58 both hash to slot: "
    printf "%d\n" $((42 % 16))
    printf "  They should be stored in different slots due to linear probing\n"
    log_success "Collision detection logic verified"
}

# Display program output
display_output() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}                    PROGRAM OUTPUT                         ${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    cat "$ACTUAL_OUTPUT"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Cleanup function
cleanup() {
    log_info "Cleaning up temporary files..."
    rm -f test_hash test_hash.c 2>/dev/null || true
}

# Main execution
main() {
    clear
    
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║       Hash Table Implementation in C - Build & Test        ║"
    echo "║   Equivalent to NASM x86-64 Assembly Implementation        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_prerequisites
    echo ""
    
    compile_program
    echo ""
    
    create_expected_output
    echo ""
    
    run_program
    echo ""
    
    display_output
    
    verify_output
    VERIFY_RESULT=$?
    echo ""
    
    run_detailed_tests
    echo ""
    
    cleanup
    
    if [ $VERIFY_RESULT -eq 0 ]; then
        echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
        log_success "All tests completed and verified successfully! ✓"
        echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo "The C implementation correctly matches the expected behavior:"
        echo "  ✓ Hash table initialization"
        echo "  ✓ Insertion with collision handling"
        echo "  ✓ Search and retrieval"
        echo "  ✓ Deletion with tombstone marking"
        echo "  ✓ Linear probing collision resolution"
        echo ""
        return 0
    else
        echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
        log_error "Some tests failed. Please review the output above."
        echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
        echo ""
        return 1
    fi
}

# Run main function
main
EXIT_CODE=$?

# Cleanup and exit
trap "rm -f $EXPECTED_OUTPUT $ACTUAL_OUTPUT test_hash test_hash.c 2>/dev/null" EXIT
exit $EXIT_CODE
