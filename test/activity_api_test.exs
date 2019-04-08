defmodule ActivityApiTest do
  use ExUnit.Case
  doctest ActivityApi

  test "greets the world" do
    assert ActivityApi.hello() == :world
  end
end
