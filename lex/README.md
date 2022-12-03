# Lexical analysis

## Introduction

Implement the regular expressions of a simple P langauage in scanner.l and generate scanner.c by using flex for the P language.

## Environment
If you haven't installed flex tool, there is a docker to render an enviroment.

>\*Compiler_Project\$cd ./lex\
\*Compiler_Project/lex\$./activate_dockers

>student@compiler\~s20:~\$make

Now in ./src, there are scanner.c and a scanner program produced.
You can test the scanner with a P language file created by yourself
>student@compiler\~s20:\~$./scanner file_name

## For example,

we write a test.pp as below:
````
// print hello world
begin
var a : integer;
var b : real;
print "hello world";
a := 1+1;
b := 1.23;
if a > 01 then
b := b*1.23e-1;
//&S-
a := 1;
//&S+
//&T-
a := 2;
//&T+
end if
end
````
Test the file by
>student@compiler\~s20:\~/src$./scanner test.pp

Your scanner should output:
````
1: // print hello world
<KWbegin>
2: begin
<KWvar>
<id: a>
<:>
<KWinteger>
<;>
3: var a : integer;
<KWvar>
<id: b>
<:>
<KWreal>
<;>
4: var b : real;
<KWprint>
<string: "hello world">
<;>
5: print "hello world";
<id: a>
<:=>
<Decimal: 1>
<+>
<Decimal: 1>
<;>
6: a := 1+1;
<id: b>
<:=>
<Float: 1.23>
<;>
7: b := 1.23;
<KWif>
<id: a>
<>>
<Octal: 01>
<KWthen>
8: if a > 01 then
<id: b>
<:=>
<id: b>
<*>
<Float: 1.23>
<id: e>
<->
<Decimal: 1>
<;>
9: b := b*1.23e-1;
10: //&S-
<id: a>
<:=>
<Decimal: 1>
<;>
11: a := 1;
12: //&S+
13: //&T-
<id: a>
<:=>
<Decimal: 2>
<;>
14: a := 2;
15: //&T+
<KWend>
<KWif>
16: end if
<KWend>
17: end
````

