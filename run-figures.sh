#!/bin/bash
for fig in R/*figure.R ; do
	echo "Now running $fig"
	Rscript $fig
done
rm Rplots.pdf
