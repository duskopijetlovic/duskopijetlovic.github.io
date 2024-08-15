---
layout: post
title: "Beginner's Introduction to Perl [DRAFT]"
date: 2024-07-24 10:58:25 -0700 
categories: perl programming tutorial cli terminal shell script it computing
            unix sysadmin learning
---

OS: 14.0-RELEASE-p6    
Shell: *tcsh* 


```
$ mkdir ~/beginner_s_introduction_to_perl
 
$ cd ~/beginner_s_introduction_to_perl
 
$ command -v perl; type perl; which perl; whereis perl
/usr/local/bin/perl
perl is /usr/local/bin/perl
/usr/local/bin/perl
perl: /usr/local/bin/perl /usr/local/lib/perl5/5.30/perl/man/man1/perl.1.gz /usr/src/contrib/file/magic/Magdir/perl
 
$ command -v env; type env; which env; whereis env
/usr/bin/env
env is /usr/bin/env
/usr/bin/env
env: /usr/bin/env /usr/share/man/man1/env.1.gz /usr/src/usr.bin/env
```


```
$ vi first.pl
```

```
$ cat first.pl
#!/usr/bin/env perl
print "Hello, World!\n";
 
$ ls -lh first.pl
-rw-r--r--  1 dusko dusko   45B Jul 24 11:02 first.pl
 
$ chmod 0744 first.pl
 
$ ls -lh first.pl
-rwxr--r--  1 dusko dusko   45B Jul 24 11:02 first.pl
```

```
$ ./first.pl
Hello, World!
```

## Variables

Perl has three types of variables: scalars, arrays and hashes.
Think of them as "things", "lists" and "dictionaries".

In Perl, all variable names are a punctuation character, a letter or underscore, and one or more alphanumeric characters or underscores.

**Scalars** are single things.

The name of a scalar begins with a dollar sign (`$`), such as `$i` or `$abacus`.

About the only basic operator that you can use on strings is concatenation.
The concatenation operator is the period (`.`).
Concatenation and addition are two different things:

```
$ cat concat.pl 
#!/usr/bin/env perl

$a = "8";        # Note the quotes.  $a is a string.
$b = $a + "1";   # "1" is a string too.
$c = $a . "1";   # But $b and $c have different values!

print "$b\n";
print "$c\n";
``` 

``` 
$ ./concat.pl
9
81
```

Just remember, the plus sign *adds* numbers and the period *puts strings together*.


**Arrays** are *lists* of scalars.

Array names begin with `@`.
You define arrays by listing their contents in parentheses, separated by commas:

```
@lotto_numbers = (1, 2, 3, 4, 5, 6);
@months = ("July", "August", "September");
```

The contents of an array are *indexed* beginning with **0**.
To retrieve the elements of an array, you replace the `@` sign with a `$` sign, and follow that with the index position of the element you want.
(It begins with a dollar sign because you're getting a scalar value.)
You can also modify it in place, just like any other scalar.

If you want to find the length of an array, use the value `$#array_name`.
This is one less than the number of elements in the array.
If the array just doesn't exist or is empty, `$#array_name` is `-1`.
If you want to resize an array, just change the value of `$#array_name`.

```
$ cat months.pl
#!/usr/bin/env perl

@months = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");

print $months[0];       # This prints "Jan"
print "\n";             # Newline must go within quotes
print "$months[9]\n";   # Oct, not Sep because indexing starts with 0

$winter_months[0] = "Dec";  # This implicitly creates @winter_months

print "$winter_months[0]\n";
print "\n";
print "$#months\n";
```

```
$ ./months.pl
Jan
Oct
Dec

11
```

**Hashes** are called "dictionaries" in some programming languages, and that's what they are: a term and a definition, or in more correct language a *key* and a *value*.
Each key in a hash has one and only one corresponding value.

The name of a hash begins with a percentage sign (`%`), like `%parents`.
You define hashes by comma-separated pairs of key and value:

```
%days_in_summer = ( "Jul" => 31, "Aug" => 31, "Sep" => 30 );
```

You can fetch any value from a hash by referring to `$hashname{key}`, or modify it in place just like any other scalar.

```
print $days_in_summer{"Sep"};   # 30
$days_in_summer{"Feb"} = 29;    # Let's assume it's a leap year
```

If you want to see what keys are in a hash, you can use the keys function with the name of the hash.
This returns a list containing all of the keys in the hash.
The list isn't always in the same order, though; while we could count on `@months` to always return Jul, Aug, Sep in that order, `keys %days_in_summer` might return them in any order whatsoever.

```
@month_list = keys %days_in_summer;
```

```
$ cat hashes.pl
#!/usr/bin/env perl

%days_in_summer = ( "Jul" => 31, "Aug" => 31, "Sep" => 30 );

print $days_in_summer{"Sep"};   # 30
print "\n";

$days_in_summer{"Mar"} = 31;

print $days_in_summer{"Mar"};
print "\n";

@month_list = keys %days_in_summer;
# @month_list is now ('Jul', 'Sep', 'Aug') !

print "\n"; 
print @month_list[0,1,2];
print "\n"; 
```

```
$ ./hashes.pl
30
31

AugJulMar
``` 

``` 
$ ./hashes.pl
30
31

MarJulAug
```

```
$ ./hashes.pl
30
31

JulSepAug
```

The three types of variables have three separate **namespaces**.
That means that `$abacus` and `@abacus` are two different variables, and `$abacus[0]` (the first element of `@abacus`) is not the same as `$abacus{0}` (the value in abacus that has the key 0).

----

# References

* [Beginner's Introduction to Perl Oct 16, 2000 by Doug Sheppard](https://www.perl.com/pub/2000/10/begperl1.html/)

