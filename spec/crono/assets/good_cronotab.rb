# frozen_string_literal: true

# This is an example of a good cronotab for tests

Crono.perform(TestJob).every 5.seconds
