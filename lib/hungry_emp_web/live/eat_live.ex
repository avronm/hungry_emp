defmodule HungryEmpWeb.EatLive do
  use HungryEmpWeb, :live_view

  alias HungryEmpWeb.Location

  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(%{}), locations: load(), filter_val: "")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Locations
        <:subtitle>Find a location for the food you crave</:subtitle>
      </.header>

      <p class="mt-8">
        Filter foods:
        <.form for={@form}>
          <input
            name="filter_val"
            class="bg-slate-300 w-full max-w-96"
            placeholder="ie. Asian, Sandwich, Chicken"
            phx-change="filter_foods"
          />
        </.form>
      </p>

      <hr />
      <table class="table-auto w-full text-left mt-10">
        <thead>
          <tr>
            <th>Name</th>
            <th>Address</th>
            <th>Food</th>
          </tr>
        </thead>
        <tbody>
          <%= for location = %Location{} <- @locations do %>
            <tr>
              <td><%= location.applicant %></td>
              <td><%= location.address %></td>
              <td><%= location.food |> highlight(@filter_val) |> raw() %></td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  def handle_event("filter_foods", %{"filter_val" => value}, socket) do
    {:noreply,
     socket
     |> assign(locations: load(value))
     |> assign(filter_val: value)}
  end

  @spec load(String.t()) :: list()
  defp load(filter_val \\ "") do
    "#{File.cwd!()}/priv/csv/Mobile_Food_Facility_Permit.csv"
    |> Path.expand(__DIR__)
    |> File.stream!()
    |> CSV.decode()
    |> Enum.split(1)
    |> elem(1)
    |> build()
    |> filter(filter_val)
  end

  @spec build([{:ok, []}]) :: list()
  defp build(rows = [row | _]) when is_list(rows) and is_tuple(row) do
    Enum.map(rows, &build/1)
  end

  @spec build({:ok, []}) :: Location.t()
  defp build(
         {:ok,
          [
            id,
            applicant,
            facility,
            cnn,
            description,
            address,
            blocklot,
            block,
            lot,
            permit,
            status,
            food,
            x,
            y,
            latitude,
            longitude,
            schedule,
            hours,
            noi,
            approved,
            received,
            prior_permit,
            expires,
            location,
            fire_districts,
            police_districts,
            supervisor_districts,
            zip_codes,
            neighborhoods
          ]}
       ),
       do: %Location{
         id: id,
         applicant: applicant,
         facility: facility,
         cnn: cnn,
         description: description,
         address: address,
         blocklot: blocklot,
         block: block,
         lot: lot,
         permit: permit,
         status: status,
         food: food,
         x: x,
         y: y,
         latitude: latitude,
         longitude: longitude,
         schedule: schedule,
         hours: hours,
         noi: noi,
         approved: approved,
         received: received,
         prior_permit: prior_permit,
         expires: expires,
         location: location,
         fire_districts: fire_districts,
         police_districts: police_districts,
         supervisor_districts: supervisor_districts,
         zip_codes: zip_codes,
         neighborhoods: neighborhoods
       }

  defp build(_), do: []

  @spec filter(list(%Location{}), String.t()) :: list(%Location{})
  defp filter(locations = [%Location{} | _], filter_val),
    do: Enum.filter(locations, fn location -> String.contains?(location.food, filter_val) end)

  @spec highlight(String.t(), String.t()) :: String.t()
  defp highlight(text, value) when is_binary(value) and byte_size(value) > 0 do
    value = value |> html_escape() |> safe_to_string()
    String.replace(text, value, "<strong class=\"bg-yellow-300\">#{value}</strong>")
  end

  defp highlight(text, _), do: text
end
