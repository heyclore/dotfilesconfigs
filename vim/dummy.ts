// Dummy JavaScript/TypeScript Code

class DummyClass {
    private dummyField: string;

    constructor(dummyField: string) {
        this.dummyField = dummyField;
    }

    public dummyMethod(): void {
        let dummyVar: number = 0;
        const dummyConst: boolean = true;
        if (dummyConst) {
            while (dummyVar < 10) {
                switch (dummyVar) {
                    case 0:
                        console.log("Zero");
                        break;
                    case 1:
                        console.log("One");
                        break;
                    default:
                        console.log("Default case");
                }
                dummyVar++;
            }
        }

        for (let i = 0; i < 5; i++) {
            if (i % 2 === 0) {
                continue;
            }
            console.log(`Loop iteration: ${i}`);
        }

        try {
            throw new Error("This is a dummy error");
        } catch (error) {
            console.log(error);
        } finally {
            console.log("Finally block executed");
        }
    }
}

interface DummyInterface {
    dummyProp: string;
    dummyMethod(input: number): boolean;
}

const dummyFunction = (param1: string, param2: number): string => {
    return `Received ${param1} and ${param2}`;
};

let dummyObject: DummyInterface = {
    dummyProp: "Test",
    dummyMethod(input: number): boolean {
        return input > 0;
    }
};

enum DummyEnum {
    First = "FIRST",
    Second = "SECOND",
    Third = "THIRD"
}

function dummySwitch(param: number): string {
    switch (param) {
        case 1:
            return "First";
        case 2:
            return "Second";
        default:
            return "Default";
    }
}

const dummyArray: number[] = [1, 2, 3, 4, 5];
dummyArray.forEach((item) => {
    console.log(item);
});

let dummySet = new Set<number>([1, 2, 3]);
dummySet.add(4);
dummySet.delete(2);

let dummyMap = new Map<string, number>();
dummyMap.set("one", 1);
dummyMap.set("two", 2);

function dummyAsyncFunction(): Promise<string> {
    return new Promise((resolve, reject) => {
        setTimeout(() => resolve("Async done!"), 1000);
    });
}

dummyAsyncFunction().then((message) => {
    console.log(message);
});

const dummyArrowFunction = (param: boolean): void => {
    if (param) {
        console.log("True");
    } else {
        console.log("False");
    }
};

let dummyArray2: any[] = [1, "text", true, null];
dummyArray2.forEach((item) => {
    console.log(item);
});

let dummyFunctionExpression = function (): void {
    console.log("Function expression called");
};

interface DummyGenerics<T> {
    value: T;
    displayValue(): void;
}

class GenericClass<T> implements DummyGenerics<T> {
    value: T;

    constructor(value: T) {
        this.value = value;
    }

    displayValue(): void {
        console.log(this.value);
    }
}

let genericInstance = new GenericClass<number>(10);
genericInstance.displayValue();

namespace DummyNamespace {
    export function dummyExportedFunction(): void {
        console.log("Function from namespace");
    }
}

DummyNamespace.dummyExportedFunction();

let dummyVariable: any = "This is a dummy value";
let anotherDummyVariable: number | string = 42;

type DummyType = { id: number; name: string };

let dummyTypedObject: DummyType = { id: 1, name: "Object" };

let dummyObject2 = {
    dummyMethod: (a: number, b: number): number => {
        return a + b;
    }
};

const dummyLet: number = 123;
const dummyConst2: string = "Hello, World";

const myPromise: Promise<void> = new Promise((resolve) => resolve());

async function asyncDummyFunction(): Promise<void> {
    await myPromise;
    console.log("Async function complete");
}

asyncDummyFunction();

function dummyReturnFunction(): string {
    return "This is a return string";
}

const dummyClassInstance = new DummyClass("dummy");

console.log(dummyClassInstance);
console.log(dummySwitch(1));
console.log(dummyFunction("param1", 5));
console.log(dummyEnum.DummyEnum.Second);

class AnotherDummyClass extends DummyClass {
    constructor(dummyField: string) {
        super(dummyField);
    }

    public anotherDummyMethod(): void {
        console.log("Another method in the subclass");
    }
}

const anotherDummyInstance = new AnotherDummyClass("Sub Dummy");
anotherDummyInstance.anotherDummyMethod();
a
