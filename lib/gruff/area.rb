# frozen_string_literal: true

require 'gruff/base'

class Gruff::Area < Gruff::Base
  def initialize(*)
    super
    @sorted_drawing = true
  end

  def draw
    super

    return unless data_given?

    @x_increment = @graph_width / (column_count - 1).to_f

    store.norm_data.each do |data_row|
      poly_points = []

      data_row.points.each_with_index do |data_point, index|
        # Use incremented x and scaled y
        new_x = @graph_left + (@x_increment * index)
        new_y = @graph_top + (@graph_height - data_point * @graph_height)

        poly_points << new_x
        poly_points << new_y

        draw_label(new_x, index)
      end

      # Add closing points, draw polygon
      poly_points << @graph_right
      poly_points << @graph_bottom - 1
      poly_points << @graph_left
      poly_points << @graph_bottom - 1

      Gruff::Renderer::Polyline.new(color: data_row.color).render(poly_points)
    end

    Gruff::Renderer.finish
  end
end
