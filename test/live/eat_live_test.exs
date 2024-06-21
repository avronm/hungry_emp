defmodule HungryEmpWeb.EatLiveTest do
  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint HungryEmpWeb

  use HungryEmpWeb.ConnCase

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/eat")
    response = html_response(conn, 200)
    {:ok, document} = Floki.parse_document(response)

    assert document |> Floki.find("header h1") |> Floki.text() =~
             "Locations"

    assert document |> Floki.find("header h1 + p") |> Floki.text() =~
             "Find a location for the food you crave"

    {:ok, _view, _html} = live(conn)
  end

  test "renders list of locations from CSV file appropriately", %{conn: conn} do
    conn = get(conn, "/eat")
    response = html_response(conn, 200)
    {:ok, document} = Floki.parse_document(response)

    assert document |> Floki.find("table tbody tr") |> length() == 629

    assert document |> Floki.find("table tbody tr:first-child td") |> Floki.text() =~
             "Datam SF LLC dba Anzu To You2535 TAYLOR STAsian Fusion - Japanese Sandwiches/Sliders/Misubi"

    assert document |> Floki.find("table tbody tr:last-child td") |> Floki.text() =~
             "May Catering501 ALABAMA STCold Truck: Sandwiches: fruit: snacks: candy: hot and cold drinks"

    {:ok, _view, _html} = live(conn)
  end

  test "renders an updated list of locations based on filter value", %{conn: conn} do
    conn = get(conn, "/eat")

    {:ok, view, _html} = live(conn)

    {:ok, change} =
      render_change(view, :filter_foods, %{filter_val: "Noodles"}) |> Floki.parse_fragment()

    highlighted = change |> Floki.find("tr strong")

    assert length(highlighted) == 52
    assert [{"strong", [{"class", "bg-yellow-300"}], ["Noodles"]} | _] = highlighted

    {:ok, change} =
      render_change(view, :filter_foods, %{filter_val: "Bacon"}) |> Floki.parse_fragment()

    highlighted = change |> Floki.find("tr strong")

    assert length(highlighted) == 13
    assert [{"strong", [{"class", "bg-yellow-300"}], ["Bacon"]} | _] = highlighted
  end
end
