import click
import os
import sys


def get_env_vars(ctx, args, incomplete):
    return [k for k in os.environ.keys() if incomplete in k]


@click.group()
def main():
    pass


@main.command(help='A command to print environment variables')
@click.argument('env_var', type=click.STRING, autocompletion=get_env_vars)
def env(env_var):
    click.echo(f'Environment check:')
    click.echo(f'  Variable : {env_var}')
    click.echo(f'  Value    : {os.environ[env_var]}')


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
