pragma solidity ^0.5.4;

contract CoreErrors {
    string constant internal ERROR_CORE_NOT_POOL = "";
    string constant internal ERROR_CORE_CANT_BE_POOL = "";

    string constant internal ERROR_CORE_TICKER_WAS_CANCELLED = "";
    string constant internal ERROR_CORE_SYNTHETIC_VALIDATION_ERROR = "";
    string constant internal ERROR_CORE_NOT_ENOUGH_TOKEN_ALLOWANCE = "";

    string constant internal ERROR_CORE_TOKEN_IDS_AND_QUANTITIES_LENGTH_DOES_NOT_MATCH = "";
    string constant internal ERROR_CORE_TOKEN_IDS_AND_DERIVATIVES_LENGTH_DOES_NOT_MATCH = "";

    string constant internal ERROR_CORE_EXECUTION_BEFORE_MATURITY_NOT_ALLOWED = "";
    string constant internal ERROR_CORE_SYNTHETIC_EXECUTION_WAS_NOT_ALLOWED = "";
    string constant internal ERROR_CORE_INSUFFICIENT_POOL_BALANCE = "CORE:INSUFFICIENT_POOL_BALANCE";

    string constant internal ERROR_CORE_CANT_CANCEL_DUMMY_ORACLE_ID = "CORE:CANT_CANCEL_DUMMY_ORACLE_ID";
    string constant internal ERROR_CORE_CANCELLATION_IS_NOT_ALLOWED = "CORE:CANCELLATION_IS_NOT_ALLOWED";

    string constant internal ERROR_CORE_UNKNOWN_POSITION_TYPE = "CORE:UNKNOWN_POSITION_TYPE";
}
