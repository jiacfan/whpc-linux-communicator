#include "TestRunner.h"

#ifdef DEBUG

#include "../utils/Logger.h"
#include "ProcessTest.h"

using namespace hpc::tests;
using namespace hpc::utils;

TestRunner::TestRunner()
{
    this->tests["SimpleEcho"] = []() { return ProcessTest::SimpleEcho(); };
    this->tests["Affinity"] = []() { return ProcessTest::Affinity(); };
    this->tests["RemainingProcess"] = []() { return ProcessTest::RemainingProcess(); };
    this->tests["ClusRun"] = []() { return ProcessTest::ClusRun(); };
}

bool TestRunner::Run()
{
    bool finalResult = true;
    Logger::Info("========================================================");
    Logger::Info("Start Testing, {0} cases in total.", this->tests.size());
    Logger::Info("========================================================");
    for (auto& t : this->tests)
    {
        Logger::Info("");
        Logger::Info("");
        Logger::Info("Testing {0}", t.first);
        Logger::Info("--------------------------------------------------------");
        bool result = t.second();
        Logger::Info("--------------------------------------------------------");
        Logger::Info("Result {0}", result ? "Passed" : "Failed");
        Logger::Info("");
        Logger::Info("");

        if (!result) finalResult = false;
    }

    return finalResult;
}

#endif // DEBUG
