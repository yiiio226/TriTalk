-- Migration: Add translations JSONB field to standard_scenes and seed data
-- Combines adding the column and populating it with initial translations for all supported languages
-- Supported Languages: en-US, en-GB, zh-CN, ja-JP, ko-KR, es-ES, es-MX, fr-FR, de-DE

-- 1. Add translations column
ALTER TABLE standard_scenes 
  ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';

COMMENT ON COLUMN standard_scenes.translations IS 
  'Localized content for title/description/goal. Supported: en-GB, zh-CN, ja-JP, ko-KR, es-ES, es-MX, fr-FR, de-DE';

-- 2. Seed translations for existing 13 standard scenes

-- 1. Order Coffee
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Order Coffee", "description": "Order a coffee", "goal": "Order a coffee"},
  "zh-CN": {"title": "点咖啡", "description": "在咖啡店点一杯咖啡", "goal": "成功点一杯咖啡"},
  "ja-JP": {"title": "コーヒーを注文する", "description": "カフェでコーヒーを注文する", "goal": "コーヒーを注文する"},
  "ko-KR": {"title": "커피 주문하기", "description": "카페에서 커피를 주문하세요", "goal": "커피를 성공적으로 주문하세요"},
  "es-ES": {"title": "Pedir un café", "description": "Pide un café en una cafetería", "goal": "Pedir un café"},
  "es-MX": {"title": "Pedir un café", "description": "Ordena un café", "goal": "Logra pedir tu café"},
  "fr-FR": {"title": "Commander un café", "description": "Commandez un café dans un café", "goal": "Commander un café"},
  "de-DE": {"title": "Kaffee bestellen", "description": "Bestellen Sie einen Kaffee", "goal": "Einen Kaffee bestellen"}
}'::jsonb WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- 2. Check-in at Immigration
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Immigration Check", "description": "Answer questions and pass through immigration", "goal": "Successfully pass immigration"},
  "zh-CN": {"title": "入境检查", "description": "回答问题并通过入境检查", "goal": "回答问题并通过入境检查"},
  "ja-JP": {"title": "入国審査", "description": "質問に答えて入国審査を通過する", "goal": "質問に答えて入国審査を通過する"},
  "ko-KR": {"title": "입국 심사", "description": "질문에 대답하고 입국 심사를 통과하세요", "goal": "질문에 대답하고 입국 심사를 통과하세요"},
  "es-ES": {"title": "Control de inmigración", "description": "Responde a las preguntas y pasa el control", "goal": "Pasar el control de inmigración"},
  "es-MX": {"title": "Migración", "description": "Contesta preguntas en migración", "goal": "Pasa los filtros de migración"},
  "fr-FR": {"title": "Contrôle d''immigration", "description": "Répondez aux questions et passez l''immigration", "goal": "Franchir l''immigration"},
  "de-DE": {"title": "Einreisekontrolle", "description": "Fragen beantworten und die Kontrolle passieren", "goal": "Einreisekontrolle passieren"}
}'::jsonb WHERE id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12';

-- 3. Lost Wallet
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Lost Wallet", "description": "Ask for help finding your wallet", "goal": "Ask for help finding your wallet"},
  "zh-CN": {"title": "丢了钱包", "description": "寻求帮助找回钱包", "goal": "寻求帮助找回钱包"},
  "ja-JP": {"title": "財布をなくした", "description": "財布を見つけるために助けを求める", "goal": "財布を見つけるために助けを求める"},
  "ko-KR": {"title": "지갑 분실", "description": "지갑을 찾는 데 도움을 요청하세요", "goal": "지갑을 찾는 데 도움을 요청하세요"},
  "es-ES": {"title": "Cartera perdida", "description": "Pide ayuda para encontrar tu cartera", "goal": "Pedir ayuda para recuperar la cartera"},
  "es-MX": {"title": "Cartera perdida", "description": "Pide ayuda para encontrar tu cartera", "goal": "Pedir ayuda para encontrar la cartera"},
  "fr-FR": {"title": "Porte-monnaie perdu", "description": "Demandez de l''aide pour retrouver votre porte-monnaie", "goal": "Retrouver votre porte-monnaie"},
  "de-DE": {"title": "Geldbörse verloren", "description": "Bitten Sie um Hilfe, Ihre Geldbörse zu finden", "goal": "Um Hilfe bitten"}
}'::jsonb WHERE id = 'c2eebc99-9c0b-4ef8-bb6d-6bb9bd380a13';

-- 4. Taking a Taxi
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Taking a Taxi", "description": "Give directions to the driver", "goal": "Reach your destination"},
  "zh-CN": {"title": "乘坐出租车", "description": "给司机指路", "goal": "到达目的地"},
  "ja-JP": {"title": "タクシーに乗る", "description": "運転手に行き先を告げる", "goal": "目的地に到着する"},
  "ko-KR": {"title": "택시 타기", "description": "기사에게 길 안내하기", "goal": "목적지에 도착하세요"},
  "es-ES": {"title": "Coger un taxi", "description": "Da indicaciones al conductor", "goal": "Llegar a tu destino"},
  "es-MX": {"title": "Tomar un taxi", "description": "Dale indicaciones al chofer", "goal": "Llegar a tu destino"},
  "fr-FR": {"title": "Prendre un taxi", "description": "Donnez des indications au chauffeur", "goal": "Arriver à destination"},
  "de-DE": {"title": "Taxi fahren", "description": "Geben Sie dem Fahrer Anweisungen", "goal": "Das Ziel erreichen"}
}'::jsonb WHERE id = 'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380a14';

-- 5. Supermarket Shopping
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Supermarket Shopping", "description": "Ask where to find items", "goal": "Find all items on your list"},
  "zh-CN": {"title": "超市购物", "description": "询问商品位置", "goal": "找到清单上的所有商品"},
  "ja-JP": {"title": "スーパーで買い物", "description": "商品の場所を尋ねる", "goal": "リストにある商品をすべて見つける"},
  "ko-KR": {"title": "슈퍼마켓 쇼핑", "description": "물건 위치 물어보기", "goal": "쇼핑 목록에 있는 모든 물건 찾기"},
  "es-ES": {"title": "En el supermercado", "description": "Pregunta dónde están los productos", "goal": "Encontrar todo lo de la lista"},
  "es-MX": {"title": "En el súper", "description": "Pregunta por los pasillos", "goal": "Encontrar tus recados"},
  "fr-FR": {"title": "Courses au supermarché", "description": "Demandez où trouver des articles", "goal": "Trouver tous les articles"},
  "de-DE": {"title": "Einkaufen im Supermarkt", "description": "Fragen Sie, wo Artikel zu finden sind", "goal": "Alle Artikel finden"}
}'::jsonb WHERE id = 'e4eebc99-9c0b-4ef8-bb6d-6bb9bd380a15';

-- 6. Asking for Directions
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Asking for Directions", "description": "Ask a local for directions", "goal": "Find the way to your destination"},
  "zh-CN": {"title": "问路", "description": "向当地人问路", "goal": "找到去目的地的路"},
  "ja-JP": {"title": "道を尋ねる", "description": "地元の人に道を尋ねる", "goal": "目的地への行き方を見つける"},
  "ko-KR": {"title": "길 묻기", "description": "현지인에게 길 물어보기", "goal": "목적지로 가는 길 찾기"},
  "es-ES": {"title": "Preguntar direcciones", "description": "Pregunta a un local por una dirección", "goal": "Encontrar el camino"},
  "es-MX": {"title": "Preguntar direcciones", "description": "Pregunta cómo llegar", "goal": "Encontrar la ruta"},
  "fr-FR": {"title": "Demander son chemin", "description": "Demandez votre chemin à un local", "goal": "Trouver votre destination"},
  "de-DE": {"title": "Nach dem Weg fragen", "description": "Fragen Sie einen Einheimischen nach dem Weg", "goal": "Den Weg finden"}
}'::jsonb WHERE id = 'f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a16';

-- 7. First Meeting
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "First Meeting", "description": "Introduce yourself to a new friend", "goal": "Get to know each other"},
  "zh-CN": {"title": "初次见面", "description": "向新朋友介绍自己", "goal": "互相了解"},
  "ja-JP": {"title": "初対面", "description": "新しい友達に自己紹介する", "goal": "お互いを知る"},
  "ko-KR": {"title": "첫 만남", "description": "새 친구에게 자기 소개하기", "goal": "서로 알아가기"},
  "es-ES": {"title": "Primera cita", "description": "Preséntate a un nuevo amigo", "goal": "Conocerse mutuamente"},
  "es-MX": {"title": "Conociendo a alguien", "description": "Preséntate con un amigo nuevo", "goal": "Conocerse"},
  "fr-FR": {"title": "Première rencontre", "description": "Presentez-vous à un nouvel ami", "goal": "Apprendre à se connaître"},
  "de-DE": {"title": "Erstes Treffen", "description": "Stellen Sie sich einem neuen Freund vor", "goal": "Sich kennenlernen"}
}'::jsonb WHERE id = '06eebc99-9c0b-4ef8-bb6d-6bb9bd380a17';

-- 8. Hotel Check-in
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Hotel Check-in", "description": "Check in to your hotel room", "goal": "Successfully check in"},
  "zh-CN": {"title": "酒店入住", "description": "办理酒店入住手续", "goal": "成功办理入住"},
  "ja-JP": {"title": "ホテルのチェックイン", "description": "ホテルの部屋にチェックインする", "goal": "チェックインを完了する"},
  "ko-KR": {"title": "호텔 체크인", "description": "호텔 객실 체크인하기", "goal": "체크인 성공하기"},
  "es-ES": {"title": "Check-in en hotel", "description": "Regístrate en tu hotel", "goal": "Hacer el check-in"},
  "es-MX": {"title": "Check-in en hotel", "description": "Regístrate en el hotel", "goal": "Hacer el check-in"},
  "fr-FR": {"title": "Check-in à l''hôtel", "description": "Enregistrez-vous à l''hôtel", "goal": "Réussir l''enregistrement"},
  "de-DE": {"title": "Hotel Check-in", "description": "Checken Sie in Ihr Hotelzimmer ein", "goal": "Erfolgreich einchecken"}
}'::jsonb WHERE id = '17eebc99-9c0b-4ef8-bb6d-6bb9bd380a18';

-- 9. Restaurant Ordering
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Restaurant Ordering", "description": "Order food at a restaurant", "goal": "Order your meal"},
  "zh-CN": {"title": "餐厅点餐", "description": "在餐厅点菜", "goal": "点餐"},
  "ja-JP": {"title": "レストランで注文", "description": "レストランで食事を注文する", "goal": "食事を注文する"},
  "ko-KR": {"title": "식당 주문", "description": "식당에서 음식 주문하기", "goal": "식사 주문하기"},
  "es-ES": {"title": "Pedir en restaurante", "description": "Pide comida en un restaurante", "goal": "Pedir la comida"},
  "es-MX": {"title": "Pedir comida", "description": "Ordena en un restaurante", "goal": "Pedir tus alimentos"},
  "fr-FR": {"title": "Commander au restaurant", "description": "Commandez un repas", "goal": "Commander votre repas"},
  "de-DE": {"title": "Im Restaurant bestellen", "description": "Bestellen Sie Essen im Restaurant", "goal": "Mahlzeit bestellen"}
}'::jsonb WHERE id = '28eebc99-9c0b-4ef8-bb6d-6bb9bd380a19';

-- 10. Job Interview
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Job Interview", "description": "Answer interview questions", "goal": "Impress the interviewer"},
  "zh-CN": {"title": "求职面试", "description": "回答面试问题", "goal": "给面试官留下好印象"},
  "ja-JP": {"title": "就職面接", "description": "面接の質問に答える", "goal": "面接官に好印象を与える"},
  "ko-KR": {"title": "취업 면접", "description": "면접 질문에 대답하기", "goal": "면접관에게 좋은 인상 남기기"},
  "es-ES": {"title": "Entrevista de trabajo", "description": "Responde preguntas de la entrevista", "goal": "Impresionar al entrevistador"},
  "es-MX": {"title": "Entrevista de trabajo", "description": "Contesta preguntas de entrevista", "goal": "Dar una buena impresión"},
  "fr-FR": {"title": "Entretien d''embauche", "description": "Répondez aux questions d''entretien", "goal": "Impressionner le recruteur"},
  "de-DE": {"title": "Vorstellungsgespräch", "description": "Beantworten Sie Bewerbungsfragen", "goal": "Den Interviewer beeindrucken"}
}'::jsonb WHERE id = '39eebc99-9c0b-4ef8-bb6d-6bb9bd380a20';

-- 11. Business Meeting
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Business Meeting", "description": "Discuss a project with colleagues", "goal": "Coordinate the project next steps"},
  "zh-CN": {"title": "商务会议", "description": "与同事讨论项目", "goal": "协调项目后续步骤"},
  "ja-JP": {"title": "ビジネス会議", "description": "同僚とプロジェクトについて話し合う", "goal": "プロジェクトの次のステップを調整する"},
  "ko-KR": {"title": "비즈니스 회의", "description": "동료와 프로젝트 논의하기", "goal": "프로젝트 다음 단계 조정하기"},
  "es-ES": {"title": "Reunión de negocios", "description": "Discute un proyecto con colegas", "goal": "Coordinar siguientes pasos"},
  "es-MX": {"title": "Junta de trabajo", "description": "Discute proyectos con colegas", "goal": "Acordar los siguientes pasos"},
  "fr-FR": {"title": "Réunion d''affaires", "description": "Discutez d''un projet avec des collègues", "goal": "Coordonner les prochaines étapes"},
  "de-DE": {"title": "Geschäftsmeeting", "description": "Besprechen Sie ein Projekt mit Kollegen", "goal": "Nächste Schritte koordinieren"}
}'::jsonb WHERE id = '4aeebc99-9c0b-4ef8-bb6d-6bb9bd380a21';

-- 12. Movie Discussion
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Movie Discussion", "description": "Talk about a movie you saw", "goal": "Share opinions about the movie"},
  "zh-CN": {"title": "电影讨论", "description": "谈论你看过的一部电影", "goal": "分享对电影的看法"},
  "ja-JP": {"title": "映画の話", "description": "見た映画について話す", "goal": "映画の感想を共有する"},
  "ko-KR": {"title": "영화 토론", "description": "본 영화에 대해 이야기하기", "goal": "영화에 대한 의견 공유하기"},
  "es-ES": {"title": "Hablar de cine", "description": "Habla sobre una película que viste", "goal": "Compartir opiniones"},
  "es-MX": {"title": "Plática de cine", "description": "Platica sobre una película", "goal": "Compartir opiniones"},
  "fr-FR": {"title": "Discussion sur un film", "description": "Parlez d''un film que vous avez vu", "goal": "Partager des opinions"},
  "de-DE": {"title": "Über Filme sprechen", "description": "Sprechen Sie über einen Film", "goal": "Meinungen austauschen"}
}'::jsonb WHERE id = '5beebc99-9c0b-4ef8-bb6d-6bb9bd380a22';

-- 13. Seeing a Doctor
UPDATE standard_scenes SET translations = '{
  "en-GB": {"title": "Seeing a Doctor", "description": "Describe your symptoms to a doctor", "goal": "Explain your symptoms and get advice"},
  "zh-CN": {"title": "看医生", "description": "向医生描述症状", "goal": "解释症状并获取建议"},
  "ja-JP": {"title": "医者にかかる", "description": "医者に症状を説明する", "goal": "症状を説明してアドバイスをもらう"},
  "ko-KR": {"title": "병원 진료", "description": "의사에게 증상 설명하기", "goal": "증상을 설명하고 조언 구하기"},
  "es-ES": {"title": "Ir al médico", "description": "Describe tus síntomas al doctor", "goal": "Explicar síntomas y recibir consejo"},
  "es-MX": {"title": "Ir al doctor", "description": "Describe tus síntomas", "goal": "Obtener diagnóstico y consejo"},
  "fr-FR": {"title": "Aller chez le médecin", "description": "Décrivez vos symptômes au médecin", "goal": "Expliquer les symptômes"},
  "de-DE": {"title": "Arztbesuch", "description": "Beschreiben Sie Ihre Symptome", "goal": "Rat einholen"}
}'::jsonb WHERE id = '6ceebc99-9c0b-4ef8-bb6d-6bb9bd380a23';
