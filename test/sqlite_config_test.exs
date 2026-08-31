defmodule SqliteConfigTest do
  use ExUnit.Case
  doctest SqliteConfig

  test "greets the world" do
    assert SqliteConfig.hello() == :world
  end
end
