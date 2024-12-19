// lib/mock/mock_data_store.dart

class MockDataStore {
  // We now store transformations dimension-wise for features.

  // Let's define some simple scalar features:
  static final Map<String, Map<String, dynamic>> features = {
    "Pitch": {
      "name": "Pitch",
      "composites": [],
      // For a scalar feature, no dimensions, so transformations = []
      "transformations": [],
    },
    "Time": {
      "name": "Time",
      "composites": [],
      "transformations": [],
    },
    "Duration": {
      "name": "Duration",
      "composites": [],
      "transformations": [],
    },

    // Compound feature with 2 composites: Pitch and Time
    "FeatureA": {
      "name": "FeatureA",
      "composites": ["Pitch", "Time"],
      // For each composite dimension, we have a list of transformations
      // Dimension 0 corresponds to "Pitch"
      // Dimension 1 corresponds to "Time"
      "transformations": [
        [
          {
            "name": "Add",
            "args": [1]
          },
          {
            "name": "Mul",
            "args": [2]
          },
          {"name": "Nop", "args": []},
          {
            "name": "Add",
            "args": [3]
          },
        ],
        [
          {
            "name": "Add",
            "args": [1]
          },
          {
            "name": "Add",
            "args": [3]
          },
          {
            "name": "Add",
            "args": [2]
          },
        ],
      ],
    },

    // Another compound feature: FeatureB
    // composites: Duration, FeatureA
    "FeatureB": {
      "name": "FeatureB",
      "composites": ["Duration", "FeatureA"],
      "transformations": [
        [
          {
            "name": "Add",
            "args": [1]
          },
          {
            "name": "Mul",
            "args": [2]
          },
          {"name": "Nop", "args": []},
          {
            "name": "Add",
            "args": [3]
          },
        ],
        [
          {
            "name": "Add",
            "args": [1]
          },
          {
            "name": "Add",
            "args": [3]
          },
          {
            "name": "Add",
            "args": [2]
          },
        ],
      ],
    },
  };

  // Transformations registry remains the same
  static final Map<String, Map<String, dynamic>> transformations = {
    "Add": {
      "name": "Add",
      "argsCount": 1,
      "description": "Adds a constant to the input index",
    },
    "Mul": {
      "name": "Mul",
      "argsCount": 1,
      "description": "Multiplies the input index by a constant",
    },
    "Nop": {
      "name": "Nop",
      "argsCount": 0,
      "description": "No operation",
    },
  };

  // Conditions registry
  static final Map<String, Map<String, dynamic>> conditions = {
    "ConditionA": {
      "name": "ConditionA",
      "description": "Triggers when input > 5",
    },
    "ConditionB": {
      "name": "ConditionB",
      "description": "Triggers when input is even",
    },
  };

  // Performative Transactions
  // A PT now has a feature and a condition.
  // Let's define PT1 as wrapping FeatureB with ConditionA.
  static final Map<String, Map<String, dynamic>> performativeTransactions = {
    "PT1": {
      "name": "PT1",
      "description": "A basic performative transaction",
      "feature": "FeatureB", // references one of our defined features
      "condition": "ConditionA",
    },
    "PT2": {
      "name": "PT2",
      "description": "A complex performative transaction",
      "feature": "FeatureA",
      "condition": "ConditionB",
    },
  };
}
