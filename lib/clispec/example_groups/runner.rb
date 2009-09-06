class RunnerExampleGroup < Spec::Example::ExampleGroup
    Spec::Example::ExampleGroupFactory.register(:runner, self)

    def self.stub_exit!
      before(:each) do
        Kernel.stubs(:exit)
      end
    end

    def self.it_exits(message, expected_status_code, options = [])
      it "exits #{message}" do
        Kernel.expects(:exit).with(expected_status_code)
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

    def run(args = [], &block)
      args = args.is_a?(String) ? args.split(' ') : args
      
      if block_given?
        open('|-') do |command|
          if command.nil?
            runner.run(args)
          else
            yield command
          end
        end
      else
        cross_streams { runner.run(args) }
      end
    end
    
    def in_stream
      @in_stream ||= StringIO.new
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
    
    def cross_streams(&block)
      # Preserve original
      stdin  = $stdin
      stdout = $stdout
      stderr = $stderr
      
      # Swap in our streams
      $stdin  = in_stream
      $stdout = out_stream
      $stderr = error_stream
      
      # Bust some ghosts
      yield
      
      # Swap 'em back
      $stdin  = stdin
      $stdout = stdout
      $stderr = stderr
    end
    
    def runner
      self.class.described_class
    end

    def when_run_with(args)
      yield
      run args
    end

    def after_running_with(args)
      run args
      yield
    end

    def running_with(args, &block)
      lambda { run(args, &block) }
    end

end
