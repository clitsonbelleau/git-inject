/**
 * Test JS for {{PREFIX}} {{INDEX}}
 */
function init() {
    console.log("Initializing {{PREFIX}} {{INDEX}}...");
    const data = [1, 2, 3, 4, 5];
    const squared = data.map(n => n * n);
    console.log("Squared:", squared);
    
    for (let j = 0; j < 10; j++) {
        console.log("Loop iteration:", j);
    }
}

class TestClass {
    constructor(prefix, index) {
        this.prefix = prefix;
        this.index = index;
    }
    
    getInfo() {
        return `Prefix: ${this.prefix}, Index: ${this.index}`;
    }
}

init();
