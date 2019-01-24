#!/bin/bash

#configuration
cd $1
rm makefile
touch makefile
touch operating_file.txt
touch operating_file_.txt

#begin_making_makefile
echo "CC = gcc" > makefile
source_files=`ls | grep ".c$" | tr '\n' ' '`
echo "OBJECTS = $source_files" >> makefile
echo "HEADERS = ./headers" >> makefile
files=`ls | grep ".c$"`
echo "$files" > operating_file.txt
i=0

#macros and others
for val in $(cat operating_file.txt)
do	
	home=`grep "#ifdef" $val| tr "#ifdef" "-D  " | tr -d ' ' | uniq`
	main=`grep "void main" $val`
	if [[ -n $main ]]
	then
		main_prog=$val
		touch main_txt.txt
		echo $main_prog >> main_txt.txt
		main_prog=`sed 's/.c/ /' main_txt.txt | tr -d ' '`
		rm main_txt.txt
	fi
	
	if [[ -n "$home" ]]
	then
		echo "$home" >> operating_file_.txt
	fi
	let i=i+1
done

macro=`cat operating_file_.txt | uniq`
macro_1=`echo "$macro"`
echo 'CFLAGS = -I$(HEADERS) '"$macro_1" >> makefile
echo 'LIBS = -lm' >> makefile
echo ' ' >> makefile
echo "$main_prog: "'$(OBJECTS)' >> makefile
echo '	$(CC) $(CFLAGS) $(OBJECTS) -o $@ $(LIBS)' >> makefile
echo '' >> makefile

for val in $(cat operating_file.txt)
do
	touch hej.txt
	HEADERY=`grep ".h\"$" $val`
	echo $HEADERY > hej.txt
	headers=`awk '{for (i=2; i<=NF; i=i+2){print "$(HEADERS)/"$i" ";}}' hej.txt | tr -d '"' | tr -d "\n"`
	objects=`echo $val | sed 's/.c/.o/'`
	echo "$objects: "'$(SOURCE)/'"$val"" $headers" >> makefile
	echo '	$(CC) $(CFLAGS)'" ./$val "'-c -o $@' >> makefile
	echo ' ' >> makefile
	rm hej.txt
done

echo 'clean:' >> makefile
echo '	rm -f *.o '"$main_prog" >> makefile
rm operating_file.txt
rm operating_file_.txt
make
