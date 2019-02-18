i2z: *.asd *.lisp Makefile
	buildapp --output i2z \
		--asdf-path `pwd`/.. \
		--asdf-tree ~/quicklisp/dists/quicklisp/software \
		--load-system i2z \
		--compress-core \
		--entry "i2z:main"

clean:
	-rm -f i2z
	-rm -f *~
