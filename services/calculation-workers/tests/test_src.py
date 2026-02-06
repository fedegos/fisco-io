# Fisco.io - Calculation Workers
# Tests mínimos para que pytest recoja al menos un test

import pytest


def test_src_import():
    """El paquete src es importable."""
    import src  # noqa: F401
    assert True


def test_calculators_module_exists():
    """El módulo calculators existe."""
    import src.calculators  # noqa: F401
    assert True


def test_consumers_module_exists():
    """El módulo consumers existe."""
    import src.consumers  # noqa: F401
    assert True


def test_processors_module_exists():
    """El módulo processors existe."""
    import src.processors  # noqa: F401
    assert True
