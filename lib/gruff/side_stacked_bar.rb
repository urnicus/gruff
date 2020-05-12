# frozen_string_literal: true

require 'gruff/side_bar'
require 'gruff/stacked_mixin'

##
# New gruff graph type added to enable sideways stacking bar charts
# (basically looks like a x/y flip of a standard stacking bar chart)
#
# alun.eyre@googlemail.com

class Gruff::SideStackedBar < Gruff::SideBar
  include StackedMixin

  # Spacing factor applied between bars
  attr_accessor :bar_spacing

  def draw
    @has_left_labels = true
    get_maximum_by_stack
    super
  end

protected

  def draw_bars
    # Setup spacing.
    #
    # Columns sit stacked.
    @bar_spacing ||= 0.9

    @bar_width = @graph_height / column_count.to_f
    height = Array.new(column_count, 0)
    length = Array.new(column_count, @graph_left)
    padding = (@bar_width * (1 - @bar_spacing)) / 2
    if @show_labels_for_bar_values
      label_values = []
      0.upto(column_count - 1) { |i| label_values[i] = { value: 0, right_x: 0 } }
    end
    store.norm_data.each_with_index do |data_row, row_index|
      data_row.points.each_with_index do |data_point, point_index|
        ## using the original calcs from the stacked bar chart to get the difference between
        ## part of the bart chart we wish to stack.
        temp1 = @graph_left + (@graph_width -
                                  data_point * @graph_width -
                                  height[point_index]) + 1
        temp2 = @graph_left + @graph_width - height[point_index] - 1
        difference = temp2 - temp1

        left_x = length[point_index] #+ 1
        left_y = @graph_top + (@bar_width * point_index) + padding
        right_x = left_x + difference
        right_y = left_y + @bar_width * @bar_spacing
        length[point_index] += difference
        height[point_index] += (data_point * @graph_width - 2)

        if @show_labels_for_bar_values
          label_values[point_index][:value] += store.data[row_index].points[point_index]
          label_values[point_index][:right_x] = right_x
        end

        # if a data point is 0 it can result in weird really thing lines
        # that shouldn't even be there being drawn on top of the existing
        # bar - this is bad
        if data_point != 0
          rect_renderer = Gruff::Renderer::Rectangle.new(color: data_row.color)
          rect_renderer.render(left_x, left_y, right_x, right_y)
          # Calculate center based on bar_width and current row
        end
        # we still need to draw the labels
        # Calculate center based on bar_width and current row
        label_center = @graph_top + (@bar_width * point_index) + (@bar_width * @bar_spacing / 2.0)
        draw_label(label_center, point_index)
      end
    end
    if @show_labels_for_bar_values
      label_values.each_with_index do |data, i|
        val = (@label_formatting || '%.2f') % data[:value]
        draw_value_label(data[:right_x] + 40, (@graph_top + (((i + 1) * @bar_width) - (@bar_width / 2))) - 12, val.commify, true)
      end
    end

    Gruff::Renderer.finish
  end
end
