import click
import click_completion
import os
import sys

click_completion.init()


@click.group()
def main():
    pass


@main.command(help='A command to print environment variables')
@click.argument('env_var', type=click.Choice(os.environ.keys()))
def env(env_var):
    click.echo(f'Environment check:')
    click.echo(f'  Variable : {env_var}')
    click.echo(f'  Value    : {os.environ[env_var]}')


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
