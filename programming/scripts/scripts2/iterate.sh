#!/bin/bash

for d in utilities/*; do
	cat $d >> usage
done
