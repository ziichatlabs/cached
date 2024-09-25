import 'package:cached/src/models/cache_peek_method.dart';
import 'package:cached/src/templates/all_params_template.dart';
import 'package:cached/src/utils/utils.dart';

class CachePeekMethodTemplate {
  CachePeekMethodTemplate(
    this.method, {
    required this.className,
  }) : paramsTemplate = AllParamsTemplate(method.params);

  final CachePeekMethod method;
  final String className;
  final AllParamsTemplate paramsTemplate;

  String generateMethod() {
    final params = paramsTemplate.generateParams();
    final paramKey = getParamKey(method.params);
    final cacheMapName = getCacheMapName(method.targetMethodName);
    final ttlMapName = getTtlMapName(method.targetMethodName);

    return '''
      @override
      ${method.returnType}? ${method.name}($params)  {
        final paramsKey = "$paramKey";
        
        ${_generateRemoveTtlLogic(
      ttlMapName,
      paramKey,
      cacheMapName,
      method.hasTtl,
    )}
        
        return $cacheMapName[paramsKey];
    }
    ''';
  }

  String _generateRemoveTtlLogic(
    String ttlMapName,
    String paramsKey,
    String cacheMapName,
    bool hasTtl,
  ) {
    if (!hasTtl) return '';

    return '''
       final now = DateTime.now();
       final cachedTtl = $ttlMapName["$paramsKey"];
       final currentTtl = cachedTtl != null ? DateTime.parse(cachedTtl) : null;

       if (currentTtl != null && currentTtl.isBefore(now)) {
          $ttlMapName.remove("$paramsKey");
          $cacheMapName.remove("$paramsKey");
       }
    ''';
  }
}
