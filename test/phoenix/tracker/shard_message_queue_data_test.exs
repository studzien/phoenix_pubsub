defmodule Phoenix.Tracker.ShardMessageQueueDataTest do
  use Phoenix.PubSub.NodeCase

  alias Phoenix.Tracker.Shard

  @pool_size 4

  defp shard_pids(server) do
    for n <- 0..(@pool_size - 1) do
      server
      |> Shard.name_for_number(n)
      |> Process.whereis()
    end
  end

  test "defaults to :on_heap for every shard in the pool" do
    server = :"#{__MODULE__}.default"
    {:ok, _pid} = start_pool(name: server, pool_size: @pool_size)

    for pid <- shard_pids(server) do
      assert is_pid(pid)
      assert Process.info(pid, :message_queue_data) ==
               {:message_queue_data, :on_heap}
    end
  end

  test "uses :off_heap for every shard when message_queue_data: :off_heap" do
    server = :"#{__MODULE__}.off_heap"

    {:ok, _pid} =
      start_pool(
        name: server,
        pool_size: @pool_size,
        message_queue_data: :off_heap
      )

    for pid <- shard_pids(server) do
      assert is_pid(pid)
      assert Process.info(pid, :message_queue_data) ==
               {:message_queue_data, :off_heap}
    end
  end
end
