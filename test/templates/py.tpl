# Test Python for {{PREFIX}} {{INDEX}}
import os
import sys
import json

def main():
    print("Starting {{PREFIX}} test {{INDEX}}")
    data = {"key": "value", "numbers": [1, 2, 3, 4, 5]}
    
    for i in range(10):
        print(f"Iteration {i}")
        
    if os.name == 'nt':
        print("Running on Windows")
    else:
        print("Running on POSIX")
        
    return 0

class DataProcessor:
    def __init__(self, data):
        self.data = data
        
    def process(self):
        return [x * 2 for x in self.data.get("numbers", [])]

if __name__ == "__main__":
    sys.exit(main())
