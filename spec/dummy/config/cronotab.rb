# frozen_string_literal: true

Crono.perform(FooCron).with_options(truncate_log: 30).every 1.minute
