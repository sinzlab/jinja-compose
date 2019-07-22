# `jinja-compose`
`jinja-compose` is a simple python script that wraps [`docker-compose`](https://docs.docker.com/compose/) to provide Jinja2 based templating ability to `docker-compose`.

## Dependencies
`nvidia-docker-compose` requires following dependencies to be installed on the system:
* Docker engine

It also depends on the `docker-compose`, `PyYAML` and `Jinja2` Python packages, which would be installed automatically during the installation step described below.


## Installing
To install the script, simply run:

```bash
$ pip install jinja-compose
```

## Using `jinja-compose`
The `jinja-compose` is a drop-in replacement for the `docker-compose`. Simply run as you would run `docker-compose`:
```bash
$ jinja-compose ...
```
Depending on how your system is configured, you may need to run the script with `sudo` (i.e. if you usually need `sudo` to run `docker`, you will need `sudo`).

Running `jinja-compose` generates a new YAML config file `jinja-compose.yml` (configurable via `-o`) locally. It is safe to delete this file in-between usages and I recommend you add this to your `.gitignore` file if you are going to use `jinja-compose` within a Git repository. Once generated, you can also use the `jinja-compose.yml` directly to launch containers directly with the standard `docker-compose`. You can do so as:
```bash
$ docker-compose -f jinja-docker-compose.yml ...
```

## Running flexibly on multi-GPU setup

When working on multi-GPU setup, you would often want to run separate container for each GPU or at least limit the visibility of GPUs to only specific Docker containers. When using `nvidia-docker2` runtime, you can control the visibility of the GPU devices by setting `NVIDIA_VISIBLE_DEVICES` environmental variable. However, doing this manually would mean that you will have to interfere with the function of `docker` and `docker-compose`, and previously there was no natural way to specify which service in the `docker-compose.yml` should be run with which GPUs. This is further complicated by the fact that different machine would have different numbers of GPUs, and thus keeping a service with `NVIDIA_VISIBLE_DEVICES=4` under `environment` section on a 2 GPU machine could launch a container with no access to GPU (note: this wouldn't error out).

### Specifying GPU target
You can specify which GPU a specific service should be run with by including specifying an appropriate value of `NVIDIA_VISIBLE_DEVICES` under `environment` heading. As in the following

```yaml
version: "2"
services
  process1:
    image: nvidia/cuda
    environment:
      - NVIDIA_VISIBLE_DEVICES=0
  process2:
    image: nvidia/cuda
    environment:
      - NVIDIA_VISIBLE_DEVICES=1,2
```

The service `process1` will now only see the first GPU while the service `process2` will see second and third GPU. If you don't specify any `NVIDIA_VISIBLE_DEVICES` under devices section, the service will automatically see all available GPUs as have been the case previously.

Although this feature will allow you to finely control which service sees which GPU(s), it is still rather inflexible as will require you to adjust the `docker-compose.yml` per computer device. This is precisely where the Jinja2 templating can help you! 

### Using [Jinja2](http://jinja.pocoo.org/) in `docker-compose.yml` file 

To support the relatively common use case of wanting to launch as many compute containers (with the same configuration) as the number of GPUs available on the target machine, `jinja-compose`, as the name suggests, supports use of [Jinja2](http://jinja.pocoo.org/). Combined with the ability to specify GPU targeting, you can write `docker-compose` config that adapts flexibility to the GPU counts. For an example if you prepare the following template and save it as `docker-compose.yml.jinja`:

```yaml
version: "2"
services:
  {% for i in range(N_GPU) %}
  notebook{{i}}:
    image: sinzlab/pytorch
    ports:
      - "300{{i}}:8888"
    environment:
      - NVIDIA_VISIBLE_DEVICES={{i}}
    volumes:
      - ./notebooks:/notebooks
  {% endfor %}
```

and specify the target Jinja2 template with `-t`/`--template` flag when you run:

```bash
$ jinja-compose --template docker-compose.yml.jinja ...
```

It will pick up the Jinja template, process it and expand it to the following `docker-compose.yml`:

```yaml
version: "2"
services:
  notebook0:
    image: sinzlab/pytorch
    ports:
      - "3000:8888"
    environment:
      - NVIDIA_VISIBLE_DEVICES=0
  notebook1:
    image: sinzlab/pytorch
    ports:
      - "3001:8888"
    environment:
      - NVIDIA_VISIBLE_DEVICES=1
  notebook2:
    image: sinzlab/pytorch
    ports:
      - "3002:8888"
    environment:
      - NVIDIA_VISIBLE_DEVICES=2
```
on a 3 GPU machine. The Jinja variable `N_GPU` automatically reflects the available number of the GPUs on the system. This `docker-compose.yml` is then processed by `jinja-compose` just like any other config file to launch GPU enabled containers.

### Generating Compose File Only

If you want to generate Jinja2 parsed compose file for later use, `-G`/`--generate` flag will make `jinja-compose` exit after generating the compose file without running `docker-compose`.

```bash
$ jinja-compose -G ...
```

## Additional command line options
For additional configurations such as specifying alternate target docker compose file name (instead of the default `jinja-compose.yml`), refer to the command line help at:

```bash
$ jinja-compose -h
```


