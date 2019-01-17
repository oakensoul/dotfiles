# -*- coding: utf-8 -*-

"""Console script for dotfiles."""
import sys
import click


@click.group()
def main():
    """Console script for dotfiles."""
    pass


@main.command()
def install():
    click.echo('Install dotfiles')


@main.command()
@click.option('--brew', default=False, help='Run Homebrew Updates')
@click.option('--aliases', default=True, help='Update bash aliases')
def update(brew: bool, aliases: bool):
    click.echo(f"Update dotfiles with Brew {brew} and Aliases {aliases}")


if __name__ == "__main__":
    sys.exit(main())  # pragma: no cover
