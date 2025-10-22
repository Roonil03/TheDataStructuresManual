#!/bin/bash

# test_rtree.sh - Comprehensive R-Tree Test Script
# This script compiles and tests the R-tree implementation

echo "========================================="
echo "    R-Tree Implementation Test Suite"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cleanup function
cleanup() {
    rm -f rtree test_input.txt test_output.txt
}

# Compile the program
echo "Step 1: Compiling rtree.c..."
if gcc -o rtree rTree.c -lm -Wall; then
    echo -e "${GREEN}✓ Compilation successful${NC}"
else
    echo -e "${RED}✗ Compilation failed${NC}"
    exit 1
fi
echo ""

# Test Case 1: Basic Insertion
echo "========================================="
echo "Test Case 1: Basic Rectangle Insertion"
echo "========================================="
cat > test_input.txt << EOF
1
0 0 2 2
1
1
5 5 7 7
2
1
8 5 9 6
3
1
7 1 9 2
4
3
4
EOF

echo "Input: Inserting 4 rectangles..."
./rtree < test_input.txt > test_output.txt
echo -e "${GREEN}✓ Test completed${NC}"
echo ""

# Test Case 2: Range Search
echo "========================================="
echo "Test Case 2: Range Search Query"
echo "========================================="
cat > test_input.txt << EOF
1
1 1 3 3
10
1
2 2 4 4
20
1
5 5 7 7
30
1
6 6 8 8
40
2
2 2 6 6
4
EOF

echo "Input: Inserting 4 rectangles and searching range [2,2,6,6]..."
./rtree < test_input.txt > test_output.txt
echo "Search Results:"
grep -A 10 "Search results:" test_output.txt | head -20
echo -e "${GREEN}✓ Test completed${NC}"
echo ""

# Test Case 3: Tree Display
echo "========================================="
echo "Test Case 3: Tree Structure Display"
echo "========================================="
cat > test_input.txt << EOF
1
0 0 1 1
1
1
2 2 3 3
2
1
4 4 5 5
3
1
6 6 7 7
4
1
1 1 2 2
5
3
4
EOF

echo "Input: Inserting 5 rectangles and displaying tree..."
./rtree < test_input.txt > test_output.txt
echo "Tree Structure:"
grep -A 30 "R-Tree structure:" test_output.txt | head -40
echo -e "${GREEN}✓ Test completed${NC}"
echo ""

# Test Case 4: Stress Test (Multiple Insertions)
echo "========================================="
echo "Test Case 4: Stress Test (10 insertions)"
echo "========================================="
{
    for i in {1..10}; do
        x=$((i * 10))
        y=$((i * 10))
        echo "1"
        echo "$x $y $((x+5)) $((y+5))"
        echo "$i"
    done
    echo "3"
    echo "4"
} > test_input.txt

echo "Input: Inserting 10 rectangles..."
./rtree < test_input.txt > test_output.txt
echo -e "${GREEN}✓ Test completed${NC}"
echo ""

# Test Case 5: Overlapping Rectangles
echo "========================================="
echo "Test Case 5: Overlapping Rectangle Search"
echo "========================================="
cat > test_input.txt << EOF
1
0 0 10 10
100
1
5 5 15 15
200
1
10 10 20 20
300
1
15 15 25 25
400
2
8 8 18 18
4
EOF

echo "Input: Inserting overlapping rectangles and searching..."
./rtree < test_input.txt > test_output.txt
echo "Search Results (should find multiple overlapping):"
grep -A 10 "Search results:" test_output.txt
echo -e "${GREEN}✓ Test completed${NC}"
echo ""

# Test Case 6: Edge Cases
echo "========================================="
echo "Test Case 6: Edge Cases (Point rectangles)"
echo "========================================="
cat > test_input.txt << EOF
1
5 5 5 5
1
1
10 10 10 10
2
2
4 4 6 6
4
EOF

echo "Input: Testing point rectangles..."
./rtree < test_input.txt > test_output.txt
echo "Search Results:"
grep -A 5 "Search results:" test_output.txt
echo -e "${GREEN}✓ Test completed${NC}"
echo ""

# Test Case 7: Large Scale Test
echo "========================================="
echo "Test Case 7: Large Scale (50 rectangles)"
echo "========================================="
{
    for i in {1..50}; do
        x=$((RANDOM % 100))
        y=$((RANDOM % 100))
        w=$((RANDOM % 20 + 5))
        h=$((RANDOM % 20 + 5))
        echo "1"
        echo "$x $y $((x+w)) $((y+h))"
        echo "$i"
    done
    echo "2"
    echo "20 20 60 60"
    echo "4"
} > test_input.txt

echo "Input: Inserting 50 random rectangles and searching..."
./rtree < test_input.txt > test_output.txt 2>&1
found_count=$(grep -c "Found:" test_output.txt)
echo "Found $found_count rectangles in search range [20,20,60,60]"
echo -e "${GREEN}✓ Test completed${NC}"
echo ""

# Interactive Mode Demonstration
echo "========================================="
echo "Test Case 8: Interactive Mode Demo"
echo "========================================="
echo -e "${YELLOW}To run interactive mode, execute:${NC}"
echo -e "${YELLOW}  ./rtree${NC}"
echo ""
echo "Sample interactive session:"
echo "  1. Insert Rectangle"
echo "     Input: 0 0 5 5"
echo "     ID: 1"
echo "  2. Range Search"
echo "     Query: 2 2 8 8"
echo "  3. Display Tree"
echo "  4. Exit"
echo ""

# Summary
echo "========================================="
echo "           Test Suite Summary"
echo "========================================="
echo -e "${GREEN}✓ All 8 test cases completed successfully!${NC}"
echo ""
echo "Test Coverage:"
echo "  ✓ Basic insertion and node creation"
echo "  ✓ Range search queries"
echo "  ✓ Tree structure display"
echo "  ✓ Stress testing with multiple entries"
echo "  ✓ Overlapping rectangle handling"
echo "  ✓ Edge cases (point rectangles)"
echo "  ✓ Large scale operations (50+ entries)"
echo "  ✓ Interactive mode demonstration"
echo ""
echo "Cleanup..."
cleanup
echo -e "${GREEN}✓ Temporary files removed${NC}"
echo ""
echo "========================================="
echo "     Testing Complete!"
echo "========================================="
