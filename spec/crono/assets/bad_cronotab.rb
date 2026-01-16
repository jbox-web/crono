# frozen_string_literal: true

# This is an example of a bad cronotab for tests

# This is an error, because you can use `on` options with
# a period less than 7 days.

Crono.perform(TestJob).every 5.days, on: :sunday
