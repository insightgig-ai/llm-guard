from typing import Dict, List, Optional, Tuple
from pydantic import BaseModel, Field

# Add this type alias at the top of the file (after imports)
VaultData = List[Tuple[str, str]]


# KEEP THESE UNCHANGED - they don't need vault_data
class ScanPromptRequest(BaseModel):
    prompt: str = Field(title="Prompt")
    scanners_suppress: List[str] = Field(title="Scanners to suppress", default=[])


class ScanPromptResponse(BaseModel):
    is_valid: bool = Field(title="Whether the prompt is safe")
    scanners: Dict[str, float] = Field(title="Risk scores of individual scanners")


# MODIFY THIS - add vault_data field
class AnalyzePromptRequest(ScanPromptRequest):
    vault_data: Optional[VaultData] = Field(
        default=None,
        title="Existing vault data to restore (for multi-turn conversations)",
        description="List of [placeholder, original_value] tuples from previous anonymization"
    )


# MODIFY THIS - add vault_data field
class AnalyzePromptResponse(ScanPromptResponse):
    sanitized_prompt: str = Field(title="Sanitized prompt")
    vault_data: VaultData = Field(
        default=[],
        title="Updated vault data (store this for output deanonymization)",
        description="List of [placeholder, original_value] tuples created during anonymization"
    )


# KEEP THESE UNCHANGED - they don't need vault_data
class ScanOutputRequest(BaseModel):
    prompt: str = Field(title="Prompt")
    output: str = Field(title="Model output")
    scanners_suppress: List[str] = Field(title="Scanners to suppress", default=[])


class ScanOutputResponse(BaseModel):
    is_valid: bool = Field(title="Whether the output is safe")
    scanners: Dict[str, float] = Field(title="Risk scores of individual scanners")


# MODIFY THIS - add vault_data field
class AnalyzeOutputRequest(ScanOutputRequest):
    vault_data: Optional[VaultData] = Field(
        default=None,
        title="Vault data from input scanning (required for Deanonymize)",
        description="List of [placeholder, original_value] tuples to use for deanonymization"
    )


# MODIFY THIS - add vault_data field
class AnalyzeOutputResponse(ScanOutputResponse):
    sanitized_output: str = Field(title="Sanitized output")
    vault_data: VaultData = Field(
        default=[],
        title="Updated vault data",
        description="List of [placeholder, original_value] tuples after processing"
    )