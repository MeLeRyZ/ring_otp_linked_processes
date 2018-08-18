defmodule Ring do
    @moduledoc """
    creates a ring of linked processes so that you can see for yourself the error being
    propagated and re-propagated to all the links.
    """
    def create_processes(n) do
        1..n |> Enum.map( fn _ -> spawn(fn ->
            loop
        end) end)
    end

    def loop do
        receive do
            {:link, link_to} when is_pid(link_to) ->
                Process.link(link_to)
                loop
            :trap_exit ->
                Process.flag(:trap_exit, true) #handles a msg to trap exits
                loop
            :crash ->
                1/0
            {:EXIT, pid, reason} -> #handles a msg to detect :DOWN msgs
                IO.puts "#{inspect self} received {:EXIT, #{inspect pid}, #{reason}}"
                loop
        end
    end

    # linkin processes: from one array of processes to enother array of linked processes
    def link_processes(procs) do
        link_processes(procs, [])
    end

    def link_processes([proc1, proc2 | rest], linked_processes) do
        send(proc1, {:link, proc2})
        link_processes([proc2 | rest], [proc1 | linked_processes]) # proc2->proc1, proc2 takes from rest
    end

    def link_processes([proc | []], linked_processes) do
        first_process = linked_processes |> List.last
        send(proc, {:link, first_process}) # connection between first and last. circle-chain
        IO.puts "OK!" # don't need booklike `:ok` - it's made automaticly :)
    end
    # Testing crashes of all chain by crashing random process in it:
    # pids |> Enum.shuffle |> List.first |> send(:crash)
    # To check that all processes die, muahahaha, :
    # pids |> Enum.map(fn pid -> Process.alive?(pid) end)
    # Linking dead process
    # iex()> Process.alive? pid
    # false
    # iex()> Process.link(pid)
    # true
    # iex()> flush
    # {:EXIT, #PID<0.167.0>, :noproc}
    # Some new stuff
    # spawn_link -> do the same as
    # pid = spawn(Worker, :loop, [])
    # Process.link(pid)


end
