/// Utility class for formatting text for display and speech
class TextFormatter {
  /// Clean text for Text-to-Speech by converting special characters to spoken words
  static String cleanForTTS(String text) {
    String cleaned = text;
    
    // Replace common special characters with spoken equivalents
    final replacements = {
      // Programming symbols
      '&&': ' and ',
      '||': ' or ',
      '!=': ' not equals ',
      '==': ' equals ',
      '<=': ' less than or equal to ',
      '>=': ' greater than or equal to ',
      '<': ' less than ',
      '>': ' greater than ',
      '++': ' plus plus ',
      '--': ' minus minus ',
      '+=': ' plus equals ',
      '-=': ' minus equals ',
      '*=': ' times equals ',
      '/=': ' divided by equals ',
      '->': ' arrow ',
      '=>': ' arrow ',
      '::': ' double colon ',
      
      // Common symbols
      '@': ' at ',
      '#': ' hash ',
      '\$': ' dollar ',
      '%': ' percent ',
      '&': ' and ',
      '*': ' asterisk ',
      '+': ' plus ',
      '-': ' minus ',
      '=': ' equals ',
      '/': ' slash ',
      '\\': ' backslash ',
      '|': ' pipe ',
      '_': ' underscore ',
      '~': ' tilde ',
      '^': ' caret ',
      
      // Brackets and quotes
      '{': ' open brace ',
      '}': ' close brace ',
      '[': ' open bracket ',
      ']': ' close bracket ',
      '(': ' open parenthesis ',
      ')': ' close parenthesis ',
      '"': ' quote ',
      "'": ' apostrophe ',
      '`': ' backtick ',
      
      // Punctuation (keep some for natural speech)
      '...': ', dot dot dot, ',
      '..': ', dot dot, ',
      ';': ', semicolon, ',
      ':': ', colon, ',
      
      // URLs and emails
      'http://': ' H T T P colon slash slash ',
      'https://': ' H T T P S colon slash slash ',
      'www.': ' W W W dot ',
      '.com': ' dot com ',
      '.org': ' dot org ',
      '.net': ' dot net ',
      '.io': ' dot I O ',
      '.ai': ' dot A I ',
    };
    
    // Apply replacements in order (longer patterns first)
    final sortedKeys = replacements.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    
    for (var key in sortedKeys) {
      cleaned = cleaned.replaceAll(key, replacements[key]!);
    }
    
    // Remove markdown formatting
    cleaned = _removeMarkdown(cleaned);
    
    // Clean up multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    // Ensure proper spacing around punctuation
    cleaned = cleaned.replaceAll(RegExp(r'\s*,\s*'), ', ');
    cleaned = cleaned.replaceAll(RegExp(r'\s*\.\s*'), '. ');
    cleaned = cleaned.replaceAll(RegExp(r'\s*!\s*'), '! ');
    cleaned = cleaned.replaceAll(RegExp(r'\s*\?\s*'), '? ');
    
    return cleaned.trim();
  }
  
  /// Remove markdown formatting for TTS
  static String _removeMarkdown(String text) {
    String cleaned = text;
    
    // Remove code blocks
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), ' code block ');
    cleaned = cleaned.replaceAll(RegExp(r'`[^`]+`'), ' code ');
    
    // Remove bold and italic
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'_([^_]+)_'), r'\1');
    
    // Remove links but keep text
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'\1');
    
    // Remove headers
    cleaned = cleaned.replaceAll(RegExp(r'^#+\s*'), '');
    
    // Remove list markers
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
    
    return cleaned;
  }
  
  /// Format text for display with proper structure
  static String formatForDisplay(String text) {
    // Keep original text but ensure proper line breaks
    String formatted = text;
    
    // Ensure proper spacing after punctuation
    formatted = formatted.replaceAll(RegExp(r'([.!?])\s*'), r'\1 ');
    
    // Clean up multiple spaces
    formatted = formatted.replaceAll(RegExp(r' +'), ' ');
    
    return formatted.trim();
  }
  
  /// Check if text contains code
  static bool containsCode(String text) {
    return text.contains('```') || 
           text.contains(RegExp(r'`[^`]+`')) ||
           text.contains(RegExp(r'\b(function|class|const|let|var|def|import|export)\b'));
  }
  
  /// Extract code blocks from text
  static List<String> extractCodeBlocks(String text) {
    final codeBlocks = <String>[];
    final regex = RegExp(r'```[\s\S]*?```');
    final matches = regex.allMatches(text);
    
    for (var match in matches) {
      codeBlocks.add(match.group(0)!);
    }
    
    return codeBlocks;
  }
}
