# Syntatic Definitions
## Introduction
[In the previous part,](https://github.com/swklein-25/Complier_Project/tree/main/lex) we have used the flex to produce a scanner.c for us. Now, we write a syntatic rules in parser.y to make a **LALR(1)** parser for the **P** langauage by using bison.
## Environment
If you haven’t installed flex and bison, there is a docker image to render an enviroment.

>\*Compiler_Project\$cd ./parser
\*Compiler_Project/parser\$./activate_dockers

After entering the docker image, enter make to build parser.
>student@compile\~s20:\~$make

Execute parser
>student@compile\~s20:\~$./parser file_name

## For example,

we write a generall.p as below:
````
/**
 * general1.p: general case 1
 */
//&T-
general1;

var a: integer;
var b, c: array 4 of integer;

func1()
begin
end
end

func2( e: integer ): boolean
begin
    return (e > 10);
end
end

begin
        var ii : integer;
        for i := 10 to 15 do
        begin
            b[i-10+1] := i*i;
            c[i*10+1] := i-b[i-10+1];
        end
        end do

        print func2();
        func1();

end
end
````
console result:
````
student@compiler-s20:~/src$ ./parser general1.p
1: /**
2:  * general1.p: general case 1
3:  */
4: //&T-
5: general1;
6:
7: var a: integer;
8: var b, c: array 4 of integer;
9:
10: func1()
11: begin
12: end
13: end
14:
15: func2( e: integer ): boolean
16: begin
17:     return (e > 10);
18: end
19: end
20:
21: begin
22:         var ii : integer;
23:         for i := 10 to 15 do
24:         begin
25:             b[i-10+1] := i*i;
26:             c[i*10+1] := i-b[i-10+1];
27:         end
28:         end do
29:
30:         print func2();
31:         func1();
32:
33: end
34: end

|--------------------------------|
|  There is no syntactic error!  |
|--------------------------------|
````
