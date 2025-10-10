#!/usr/bin/env dart

import 'dart:io';

/// Test runner script for PetLink testing suite
///
/// This script provides convenient commands for running different types of tests
/// and generating test reports.

void main(List<String> arguments) async {
  if (arguments.isEmpty) {
    printUsage();
    return;
  }

  final command = arguments[0];

  switch (command) {
    case 'all':
      await runAllTests();
      break;
    case 'unit':
      await runUnitTests();
      break;
    case 'integration':
      await runIntegrationTests();
      break;
    case 'widget':
      await runWidgetTests();
      break;
    case 'coverage':
      await runTestsWithCoverage();
      break;
    case 'watch':
      await runTestsInWatchMode();
      break;
    case 'generate-mocks':
      await generateMocks();
      break;
    case 'clean':
      await cleanTestFiles();
      break;
    case 'help':
      printUsage();
      break;
    default:
      print('Unknown command: $command');
      printUsage();
      exit(1);
  }
}

void printUsage() {
  print('''
PetLink Test Runner

Usage: dart test/run_tests.dart <command>

Commands:
  all              Run all tests (unit, integration, widget)
  unit             Run unit tests only
  integration      Run integration tests only
  widget           Run widget tests only
  coverage         Run tests with coverage report
  watch            Run tests in watch mode
  generate-mocks   Generate mock files using build_runner
  clean            Clean generated test files
  help             Show this help message

Examples:
  dart test/run_tests.dart all
  dart test/run_tests.dart unit
  dart test/run_tests.dart coverage
  dart test/run_tests.dart generate-mocks
''');
}

Future<void> runAllTests() async {
  print('🧪 Running all tests...\n');

  final result = await Process.run('flutter', ['test'], runInShell: true);

  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }

  exit(result.exitCode);
}

Future<void> runUnitTests() async {
  print('🔬 Running unit tests...\n');

  final result = await Process.run('flutter', [
    'test',
    'test/unit/',
  ], runInShell: true);

  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }

  exit(result.exitCode);
}

Future<void> runIntegrationTests() async {
  print('🔗 Running integration tests...\n');

  final result = await Process.run('flutter', [
    'test',
    'test/integration/',
  ], runInShell: true);

  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }

  exit(result.exitCode);
}

Future<void> runWidgetTests() async {
  print('🎨 Running widget tests...\n');

  final result = await Process.run('flutter', [
    'test',
    'test/widget_test.dart',
  ], runInShell: true);

  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }

  exit(result.exitCode);
}

Future<void> runTestsWithCoverage() async {
  print('📊 Running tests with coverage...\n');

  // Run tests with coverage
  final testResult = await Process.run('flutter', [
    'test',
    '--coverage',
  ], runInShell: true);

  print(testResult.stdout);
  if (testResult.stderr.isNotEmpty) {
    print('Errors:');
    print(testResult.stderr);
  }

  if (testResult.exitCode == 0) {
    print('\n✅ Tests passed! Coverage report generated at coverage/lcov.info');

    // Check if genhtml is available for HTML coverage report
    final genhtmlResult = await Process.run('genhtml', [
      '--version',
    ], runInShell: true);
    if (genhtmlResult.exitCode == 0) {
      print('📈 Generating HTML coverage report...');
      final htmlResult = await Process.run('genhtml', [
        'coverage/lcov.info',
        '-o',
        'coverage/html',
      ], runInShell: true);

      if (htmlResult.exitCode == 0) {
        print('✅ HTML coverage report generated at coverage/html/index.html');
      } else {
        print(
          '⚠️  Could not generate HTML coverage report. Install lcov for HTML reports.',
        );
      }
    } else {
      print(
        '⚠️  genhtml not found. Install lcov to generate HTML coverage reports.',
      );
    }
  }

  exit(testResult.exitCode);
}

Future<void> runTestsInWatchMode() async {
  print('👀 Running tests in watch mode...\n');
  print('Press Ctrl+C to stop watching.\n');

  final result = await Process.run('flutter', [
    'test',
    '--watch',
  ], runInShell: true);

  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }

  exit(result.exitCode);
}

Future<void> generateMocks() async {
  print('🔧 Generating mock files...\n');

  final result = await Process.run('dart', [
    'run',
    'build_runner',
    'build',
  ], runInShell: true);

  print(result.stdout);
  if (result.stderr.isNotEmpty) {
    print('Errors:');
    print(result.stderr);
  }

  if (result.exitCode == 0) {
    print('✅ Mock files generated successfully!');
  } else {
    print('❌ Failed to generate mock files');
  }

  exit(result.exitCode);
}

Future<void> cleanTestFiles() async {
  print('🧹 Cleaning test files...\n');

  // Clean build_runner generated files
  final buildResult = await Process.run('dart', [
    'run',
    'build_runner',
    'clean',
  ], runInShell: true);

  print(buildResult.stdout);
  if (buildResult.stderr.isNotEmpty) {
    print('Errors:');
    print(buildResult.stderr);
  }

  // Clean coverage files
  final coverageDir = Directory('coverage');
  if (coverageDir.existsSync()) {
    coverageDir.deleteSync(recursive: true);
    print('🗑️  Removed coverage directory');
  }

  print('✅ Test files cleaned successfully!');
  exit(0);
}
