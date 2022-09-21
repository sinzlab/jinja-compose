all:
	@echo 'MakeFile for jinja-compose packaging                                              '
	@echo '                                                                              '
	@echo 'make sdist                              Creates source distribution           '
	@echo 'make wheel                              Creates Wheel distribution            '
	@echo 'make pypi                               Package and upload to PyPI            '
	@echo 'make pypitest                           Package and upload to PyPI test server'
	@echo 'make clean                              Remove all build related directories  '
	

sdist:
	python setup.py sdist >/dev/null 2>&1

sdist3:
	python3 setup.py sdist >/dev/null 2>&1

wheel2:
	python setup.py bdist_wheel >/dev/null 2>&1

wheel3:
	python3 setup.py bdist_wheel >/dev/null 2>&1

pypi:clean sdist sdist3 wheel2 wheel3
	twine upload dist/*
	
pypitest: clean sdist wheel
	twine upload -r pypitest dist/*

clean:
	rm -rf dist && rm -rf build && rm -rf *.egg-info




