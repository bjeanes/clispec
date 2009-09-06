class RunnerExampleGroup < Spec::Example::ExampleGroup
    Spec::Example::ExampleGroupFactory.register(:runner, self)

    def self.stub_exit!
      before(:each) do
        p Spec::Runner.configuration.mock_framework.to_s
        case Spec::Runner.configuration.mock_framework.to_s
          when /rspec/ then Kernel.stub!(:exit)
          when /mocha/ then Kernel.stubs(:exit)
        end
      end
    end

    def self.it_exits(message, expected_status_code, options = [])
      it "exits #{message}" do
        Kernel.should_receive(:exit).with(expected_status_code)
        run(options[:when_run_with] || '')
      end
    end

    def self.it_exits_with_error_code(options = {})
      expected_status_code = options[:error_code] || 1
      it_exits("with error code #{expected_status_code}", expected_status_code, options)
    end

    def self.it_exits_successfully(options = {})
      expected_status_code = options[:error_code] || 0
      it_exits("without error (#{expected_status_code})", expected_status_code, options)
    end

    def run(args = [])
      args = args.is_a?(String) ? args.split(' ') : args
      self.class.described_class.run(args, out_stream, error_stream)
    end

    def out_stream
      @out_stream ||= StringIO.new
    end

    def error_stream
      @error_stream ||= StringIO.new
    end

    def output
      out_stream.string
    end

    def error
      error_stream.string
    end

    def when_run_with(args)
      yield
      run args
    end

    def after_running_with(args)
      run args
      yield
    end

    def running_with(args)
      lambda { run(args) }
    end

end
