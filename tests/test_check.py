#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Tests for `check` command."""


import unittest
import os
from click.testing import CliRunner

from dotfiles import check


class TestCheckCommand(unittest.TestCase):

    def setUp(self):
        self.runner = CliRunner()
        """Set up test fixtures, if any."""

    def tearDown(self):
        """Tear down test fixtures, if any."""

    def invoke(self, **cli_args):
        return self.runner.invoke(check.main, **cli_args)

    def test_check_main(self):
        """Test the check commands."""
        result = self.invoke()
        assert result.exit_code == 0
        assert 'Usage' in result.output

    def test_help(self):
        result = self.runner.invoke(check.main, ['--help'])
        assert result.exit_code == 0
        assert '--help  Show this message and exit.' in result.output

    def test_check_key(self):
        os.environ["TEST_VAR"] = 'test01'
        result = self.runner.invoke(check.main, ['env', 'TEST_VAR'])
        assert result.exit_code == 0
        assert 'Environment' in result.output
        assert 'Variable : TEST_VAR' in result.output
        assert 'Value    : test01' in result.output
