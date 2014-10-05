defmodule Race.Racer do
    @moduledoc ~S"""
    This module uses an `Agent` to represent a `racer` and its current progress.
    """

    @doc ~S"""
    Creates a new `racer` agent, which stores its progress as an integer.

    ## Examples

        iex> {:ok, racer} = Race.Racer.create
        iex> is_pid racer
        true
    
    A `racer`'s progress is initialized to 0.

        iex> {:ok, racer} = Race.Racer.create
        iex> Agent.get(racer, fn x -> x end)
        0
        
    """
    def create do
        Agent.start_link(fn -> 0 end)
    end

    @doc ~S"""
    Moves the `racer` forward between 1 and 3 steps.
    
    ## Examples

        iex> {:ok, racer} = Race.Racer.create
        iex> init_pos = Race.Racer.get_progress(racer)
        iex> Race.Racer.move(racer)
        iex> init_pos < Race.Racer.get_progress(racer)
        true
    """
    def move(racer) when is_pid(racer) do
        :random.seed(:erlang.now)
        steps = :random.uniform(3)
        Agent.cast(racer, &(&1 + steps))
    end

    @doc ~S"""
    Returns a `racer`'s current progress.

    ## Examples
        
        iex> {:ok, racer} = Race.Racer.create
        iex> Race.Racer.get_progress(racer)
        0

        iex> {:ok, racer} = Race.Racer.create
        iex> Race.Racer.move(racer)
        iex> cur_pos = Race.Racer.get_progress(racer)
        iex> cur_pos > 0
        true
    """
    def get_progress(racer) when is_pid(racer), do: Agent.get(racer, fn x -> x end)

end