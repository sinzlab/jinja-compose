from setuptools import setup

setup(name='jinja-compose',
      version='0.0.1',
      description='docker-compose wrapper with Jinja support',
      url='https://github.com/sinzlab/jinja-compose',
      author='Edgar Y. Walker',
      author_email='edgar.y.walker@mnf.uni-tuebingen.de',
      license='MIT',
      packages=[],
      install_requires=['docker-compose', 'pyyaml', 'jinja2'],
      scripts=['bin/jinja-compose']
      )
