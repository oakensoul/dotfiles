#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Tests for `dotfiles` package."""


import unittest
from click.testing import CliRunner

from dotfiles import cli


class TestDotfiles(unittest.TestCase):
    """Tests for `dotfiles` package."""

    def setUp(self):
        self.runner = CliRunner()
        """Set up test fixtures, if any."""

    def tearDown(self):
        """Tear down test fixtures, if any."""

    def invoke(self, args):
        return self.runner.invoke(cli.main, args)

    def test_cli_main(self):
        """Test the CLI."""
        result = self.invoke([])
        assert result.exit_code == 0
        assert 'Usage' in result.output

    def test_help(self):
        result = self.invoke(['--help'])
        assert result.exit_code == 0
        assert '--help  Show this message and exit.' in result.output

    def test_install(self):
        result = self.invoke(['install'])
        assert result.exit_code == 0
        assert 'Install dotfiles' in result.output

    def test_update(self):
        result = self.invoke(['update'])
        assert result.exit_code == 0
        assert 'Update dotfiles' in result.output
        assert 'Brew False' in result.output
        assert 'Aliases True' in result.output

