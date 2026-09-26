import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../utils/language_manager.dart';
import '../../utils/theme_manager.dart';

class HrTemplatesSheet extends StatefulWidget {
  final String? defaultCompanyName;
  final String? defaultPosition;

  const HrTemplatesSheet({
    super.key,
    this.defaultCompanyName,
    this.defaultPosition,
  });

  static void show(BuildContext context, {String? defaultCompanyName, String? defaultPosition}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HrTemplatesSheet(
        defaultCompanyName: defaultCompanyName,
        defaultPosition: defaultPosition,
      ),
    );
  }

  @override
  State<HrTemplatesSheet> createState() => _HrTemplatesSheetState();
}

class _HrTemplatesSheetState extends State<HrTemplatesSheet> {
  int _selectedCategoryIndex = 0;

  List<Map<String, String>> _getTemplates() {
    final lang = LanguageManager.current;
    final company = widget.defaultCompanyName?.isNotEmpty == true
        ? widget.defaultCompanyName!
        : (lang == AppLanguage.en
            ? '[Company Name]'
            : (lang == AppLanguage.ja
                ? '[企業名]'
                : (lang == AppLanguage.ko ? '[회사명]' : '[Nama Perusahaan]')));
    final position = widget.defaultPosition?.isNotEmpty == true
        ? widget.defaultPosition!
        : (lang == AppLanguage.en
            ? '[Applied Position]'
            : (lang == AppLanguage.ja
                ? '[応募職種]'
                : (lang == AppLanguage.ko ? '[지원 포지션]' : '[Posisi yang Dilamar]')));

    if (lang == AppLanguage.ja) {
      return [
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': '選考状況のお伺い（メール）',
          'desc': '応募から1週間以上連絡がない場合の丁寧な確認メール。',
          'subject': '応募職種（$position）の選考状況につきまして【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              '先日応募いたしました「$position」職種の選考状況につきまして、念のためご確認させていただきたくご連絡差し上げました。\n\n'
              '現在も貴社でのポジションに大変関心を持っております。追加で必要な書類やポートフォリオ等がございましたら、いつでも迅速にご提出いたします。\n\n'
              'ご多忙の折、大変恐れ入りますが、ご確認のほどよろしくお願い申し上げます。\n\n'
              '--------------------------------------------------\n'
              '[氏名]\n'
              '電話番号: [電話番号]\n'
              'メール: [メールアドレス]\n'
              '--------------------------------------------------',
        },
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': 'チャットでの簡易確認（Wantedly / LINE等）',
          'desc': 'メッセージ機能でカジュアルかつ簡潔に確認する文面。',
          'subject': '$position 選考状況の確認【[氏名]】',
          'body': '$company 採用担当者様\n\n'
              'お世話になっております。[氏名]です。\n\n'
              '先日応募させていただきました「$position」について、現在の選考の進捗状況をお伺いできますでしょうか。\n\n'
              'お忙しいところ恐れ入りますが、何卒よろしくお願いいたします！🙏',
        },
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': '面接結果のお伺い',
          'desc': '面接後5〜7営業日経過した後の確認。',
          'subject': '【選考状況のお伺い】$position 面接結果につきまして【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              '[日付]に実施していただきました「$position」の面接につきまして、その後の選考状況はいかがでしょうか。\n\n'
              '面接を通じ、貴社への志望度がより一層高まっております。選考結果のご連絡時期など、差し支えない範囲でご教示いただけますと幸いです。\n\n'
              'お手数をおかけいたしますが、よろしくお願い申し上げます。\n\n'
              '[氏名]',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': '面接日程のご承諾',
          'desc': '面接案内を受けた際の日程確定・確認連絡。',
          'subject': '面接日程承諾の件（$position）【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n'
              '面接のご案内をいただき、誠にありがとうございます。\n\n'
              'ご提示いただきました下記の日程で参加させていただきます。\n\n'
              '・日時：[月 日 (曜日) 時間]\n'
              '・場所 / 形式：[Google Meet / Zoom / 貴社オフィス]\n\n'
              '当日はどうぞよろしくお願い申し上げます。\n\n'
              '--------------------------------------------------\n'
              '[氏名]\n'
              '[連絡先]\n'
              '--------------------------------------------------',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': '面接のお礼（面接後24時間以内）',
          'desc': '面接当日に送る感謝のメール。好印象を残せます。',
          'subject': '面接のお礼（$position）【[氏名]】',
          'body': '$company [面接官様 / 採用担当者様]\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              '本日はお忙しい中、「$position」の面接のお時間をいただき、誠にありがとうございました。\n\n'
              '事業への想いやチームの具体的な課題について直接お話を伺い、貴社で貢献したいという思いが一段と強くなりました。\n\n'
              '取り急ぎ、面接のお礼を申し上げます。引き続きよろしくお願いいたします。\n\n'
              '[氏名]',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': '面接日程の再調整（リスケジュール）',
          'desc': '急用でやむを得ず日程変更をお願いする場合。',
          'subject': '面接日程再調整のお願い（$position）【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              'この度は面接の機会をいただき、誠にありがとうございます。\n\n'
              '大変恐縮ではございますが、どうしても外せない所用（[理由]）が生じてしまい、指定の日時にお伺いすることが難しくなってしまいました。直前のご連絡となり誠に申し訳ございません。\n\n'
              '誠に勝手なお願いで大変恐縮ですが、下記の日程で再度調整いただくことは可能でしょうか。\n\n'
              '・候補1：[月 日 (曜日) 時間]\n'
              '・候補2：[月 日 (曜日) 時間]\n\n'
              'ご迷惑をおかけいたしますが、ご検討のほど何卒よろしくお願い申し上げます。\n\n'
              '[氏名]',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': '課題・技術テスト受領連絡',
          'desc': '技術課題の受け取りと提出目安の共有。',
          'subject': '【受領のご連絡】$position 課題受領につきまして【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              '「$position」選考の課題内容を受領いたしました。ご案内いただきありがとうございます。\n\n'
              '内容を確認の上、[月 日 (曜日) 時間] までに提出できるよう進めさせていただきます。万が一ご質問事項が生じた際は、改めてご連絡いたします。\n\n'
              '引き続きよろしくお願い申し上げます。\n\n'
              '[氏名]',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': '内定への御礼・承諾',
          'desc': '内定通知を受けた際の御礼と承諾・確認連絡。',
          'subject': '内定通知への御礼（$position）【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              'この度は「$position」の内定通知をいただき、誠にありがとうございます。大変光栄に思っております。\n\n'
              'ご提示いただきました労働条件を確認させていただきました。[ぜひ貴社の一員として貢献いたしたく、内定をお受けいたします / 入社日や詳細条件につきまして、一度短時間お打ち合わせのお時間をいただけますと幸いです]。\n\n'
              '今後の手続きにつきましても、どうぞよろしくお願い申し上げます。\n\n'
              '[氏名]',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': '待遇・条件面の相談',
          'desc': '給与や手当・働き方について相談したい場合。',
          'subject': '条件面に関するご相談（$position）【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              'この度は魅力的な条件提示をいただき、誠にありがとうございます。\n\n'
              'ご提示いただいた条件を踏まえ、ぜひ貴社に入社したいと考えておりますが、提示いただいた給与条件に関しまして、[これまでの実務実績や責任範囲]を踏まえ、[希望条件／給与額]についてご相談の余地はございますでしょうか。\n\n'
              '双方にとって最善の形で合意できるよう前向きに検討させていただきたく存じます。恐れ入りますが、ご一考いただけますと幸いです。\n\n'
              '[氏名]',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': '内定回答期限の延長依頼',
          'desc': '慎重に検討・家族と相談するための期間延長。',
          'subject': '内定回答期限に関するご相談（$position）【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              'この度は内定のご連絡をいただき、重ねて御礼申し上げます。\n\n'
              '大変恐れ入りますが、家族との相談や今後の環境調整をしっかりと行い、納得した上で決断を下したく、回答期限を【[月 日 (曜日)]】までお待ちいただくことは可能でしょうか。\n\n'
              'お忙しいところご無理を申し上げ大変恐縮ですが、ご検討のほど何卒よろしくお願い申し上げます。\n\n'
              '[氏名]',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': '内定辞退のご連絡',
          'desc': '角を立てずに誠意を持ってお断りする文面。',
          'subject': '内定に関するご連絡（$position）【[氏名]】',
          'body': '$company 採用ご担当者様\n\n'
              'お世話になっております。[氏名]と申します。\n\n'
              'この度は「$position」の内定をいただき、誠にありがとうございました。\n\n'
              '内定のご連絡をいただいてから真剣に熟慮を重ねてまいりましたが、誠に心苦しいながら、今回は内定を辞退させていただきたくご連絡いたしました。[自身のキャリアの方向性を再考した結果、別の機会に進むことを決断いたしました]。\n\n'
              '選考に貴重なお時間を割いてくださった皆様には、深く感謝申し上げますとともに、ご期待に沿えず大変申し訳ございません。\n\n'
              '略儀ではございますが、メールにてお詫びとご報告を申し上げます。貴社のますますのご発展を心よりお祈り申し上げます。\n\n'
              '[氏名]',
        },
      ];
    }

    if (lang == AppLanguage.ko) {
      return [
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': '서류 전형 진행상황 문의 (이메일)',
          'desc': '지원 후 7일 이상 경과했을 때 정중하게 확인하는 양식.',
          'subject': '[$company] $position 지원 결과 확인 문의 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '$position 포지션에 지원한 [성함]입니다.\n\n'
              '지난 [지원 일자]에 지원서를 접수한 후, 채용 전형의 진행 일정 및 결과 발표 시점에 대해 여쭙고자 연락드렸습니다.\n\n'
              '여전히 $company의 $position 역할에 큰 관심을 가지고 있으며, 추가로 검토에 필요한 자료나 포트폴리오가 있다면 언제든 전달드리겠습니다.\n\n'
              '바쁘신 업무 중에 확인해 주셔서 감사합니다.\n\n'
              '[성함] 드림\n'
              '연락처: [전화번호]\n'
              '링크드인: [링크]',
        },
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': '간단한 메신저/문자 문의 (카톡 / 문자)',
          'desc': '채용 담당자 번호나 메신저로 부담 없이 문의하는 양식.',
          'subject': '$position 지원 문의 - [성함]',
          'body': '안녕하세요 담당자님, $position 포지션에 지원한 [성함]입니다.\n\n'
              '지원서 검토가 잘 진행되고 있는지 가볍게 문의드리고자 연락드렸습니다. 혹시 대략적인 일정이나 업데이트된 내용이 있을까요?\n\n'
              '바쁘실 텐데 확인 감사드립니다! 🙏',
        },
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': '면접 전형 결과 문의',
          'desc': '면접 후 5~7영업일이 지난 시점의 문의.',
          'subject': '[$company] $position 면접 결과 안내 문의 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '지난 [면접 날짜]에 $position 포지션 면접에 참여했던 [성함]입니다.\n\n'
              '면접을 통해 팀의 비전과 역할에 대해 더욱 깊이 이해할 수 있었으며, 합류하고자 하는 열정도 한층 더 커졌습니다. 혹시 면접 결과 발표 일정에 대해 안내받을 수 있을지 조심스럽게 여쭙니다.\n\n'
              '일정에 참고할 수 있도록 편하신 때에 회신 주시면 감사하겠습니다.\n\n'
              '[성함] 드림',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': '면접 일정 확정 및 회신',
          'desc': '면접 제안을 받고 일정을 확정하는 답변.',
          'subject': '[$company] $position 면접 일정 참석 확인 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '면접에 초대해 주셔서 진심으로 감사드립니다.\n\n'
              '안내해 주신 아래 일정에 맞춰 참석하도록 하겠습니다.\n\n'
              '• 일시: [월 일(요일) 시간]\n'
              '• 장소/링크: [Google Meet / Zoom / 회사 사옥]\n\n'
              '면접 자리에서 유익한 대화를 나눌 수 있기를 기대하겠습니다. 감사합니다.\n\n'
              '[성함] 드림\n'
              '[연락처]',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': '면접 감사 메일 (당일/24시간 이내)',
          'desc': '면접 직후 긍정적인 인상을 남기는 감사 편지.',
          'subject': '[$company] 오늘 $position 면접 감사드립니다 - [성함]',
          'body': '$company [면접관님 / 채용 담당자님], 안녕하세요.\n\n'
              '오늘 바쁘신 일정 중에도 $position 면접을 위해 귀한 시간 내어주셔서 진심으로 감사드립니다.\n\n'
              '팀이 마주한 과제와 앞으로의 방향성에 대해 이야기를 나누며, 제가 가진 역량으로 팀에 기여할 수 있다는 확신을 갖게 되었습니다.\n\n'
              '추가로 필요하신 자료나 레퍼런스가 있다면 편하게 말씀해 주세요. 감사합니다.\n\n'
              '[성함] 드림',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': '면접 일정 변경(조율) 요청',
          'desc': '피치 못할 사정으로 일정 변경을 부탁드릴 때.',
          'subject': '[$company] $position 면접 일정 변경 요청의 건 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '면접 기회를 주셔서 진심으로 감사드립니다.\n\n'
              '다름이 아니라, 기존에 정해주신 일정에 부득이한 사정([간략한 사유])이 생겨 부득이하게 참석이 어렵게 되었습니다. 중요한 일정에 번거로움을 드려 대단히 죄송합니다.\n\n'
              '혹시 가능하시다면 아래 일정 중으로 변경이 가능할지 조율을 부탁드려도 될까요?\n\n'
              '• 1순위: [월 일(요일) 시간]\n'
              '• 2순위: [월 일(요일) 시간]\n\n'
              '너른 양해를 부탁드리며, 확인 부탁드립니다. 감사합니다.\n\n'
              '[성함] 드림',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': '과제/테스트 수령 확인',
          'desc': '과제 수령 및 목표 제출 시점 공유.',
          'subject': '[$company] $position 직무 과제 수령 확인 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '보내주신 $position 포지션 과제 가이드와 문제를 잘 전달받았습니다.\n\n'
              '안내해 주신 기준에 맞춰 꼼꼼히 준비하여 [월 일(요일) 시간] 전까지 제출하도록 하겠습니다. 진행 중 문의사항이 생기면 다시 연락드리겠습니다.\n\n'
              '감사합니다.\n\n'
              '[성함] 드림',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': '처우 제안(오퍼) 회신',
          'desc': '최종 합격 제안에 대한 긍정적이고 프로페셔널한 답변.',
          'subject': '[$company] $position 입사 제안에 감사드립니다 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '$position 포지션에 최종 합격 및 처우 제안을 전해주셔서 진심으로 감사드립니다. 좋은 소식을 듣게 되어 매우 기쁩니다.\n\n'
              '제안해 주신 조건들을 잘 살펴보았습니다. [기쁜 마음으로 입사 제안을 수락하고자 합니다 / 입사일 및 복리후생 세부사항에 대해 간단히 논의를 나눌 수 있을까요?].\n\n'
              '통화나 미팅이 가능하신 편한 시간을 알려주시면 감사하겠습니다.\n\n'
              '[성함] 드림',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': '처우 및 연봉 협의 요청',
          'desc': '근거를 갖춘 정중한 보상 조율 메일.',
          'subject': '[$company] $position 처우 협의에 관한 문의 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '$position 포지션에 입사 제안을 주셔서 다시 한번 감사드립니다. 귀사에 합류하여 팀과 함께 성장하고 싶은 열정이 큽니다.\n\n'
              '제안해 주신 처우 패키지와 관련하여, 제가 맡게 될 책임과 [관련 전문 경력]을 바탕으로 기본급 [희망 금액] 또는 [특정 복리후생/근무형태]에 대해 조금 더 긍정적으로 검토해 주실 수 있을지 조심스럽게 여쭙니다.\n\n'
              '서로 만족할 수 있는 좋은 방향으로 논의되기를 희망합니다. 검토 부탁드립니다.\n\n'
              '[성함] 드림',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': '입사 결정 기한 연장 요청',
          'desc': '충분한 검토를 위해 2~3일 여유를 요청할 때.',
          'subject': '[$company] $position 최종 결정 기한 관련 문의 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '좋은 제안을 주셔서 감사드립니다. 중요한 결정인 만큼 가족과 상의하고 제안 내용을 면밀히 검토하고자 합니다.\n\n'
              '혹시 최종 회신 기한을 [월 일(요일)]까지 며칠 연장해 주시는 것이 가능할지 조율을 부탁드립니다.\n\n'
              '배려해 주셔서 깊이 감사드립니다.\n\n'
              '[성함] 드림',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': '입사 제안 정중한 고사',
          'desc': '관계를 해치지 않고 매너 있게 거절하는 양식.',
          'subject': '[$company] $position 입사 제안 관련 회신 - [성함]',
          'body': '$company 채용 담당자님, 안녕하세요.\n\n'
              '$position 포지션으로 귀한 입사 기회를 주셔서 진심으로 감사드립니다. 전형 과정 동안 보여주신 친절과 배려에 깊은 인상을 받았습니다.\n\n'
              '많은 고민과 신중한 검토 끝에, 현재 저의 커리어 방향성과 조금 더 부합하는 기회를 선택하게 되어 아쉽게도 이번 제안을 정중히 사양하게 되었습니다.\n\n'
              '좋은 기회를 주셨음에도 기대에 부응하지 못해 송구스럽습니다. $company의 무궁한 발전을 진심으로 기원하며, 추후 좋은 인연으로 다시 뵐 수 있기를 희망합니다.\n\n'
              '[성함] 드림',
        },
      ];
    }

    if (lang == AppLanguage.en) {
      return [
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': 'Job Application Follow-Up',
          'desc': 'Polite check-in if you haven\'t heard back after 7+ days.',
          'subject': 'Following up on $position application - [Your Name]',
          'body': 'Hi $company Recruiting Team,\n\n'
              'I\'m checking in on my application for the $position role submitted on [Date / last week].\n\n'
              'I\'m very excited about this role and wanted to see if there are any updates on the hiring timeline. Please let me know if you need any additional work samples or details from my end.\n\n'
              'Thanks for your time,\n[Your Name]\n[Phone Number / WhatsApp]\n[LinkedIn Profile]',
        },
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': 'Quick WhatsApp Follow-Up',
          'desc': 'Direct, friendly, and natural message for recruiter WhatsApp chat.',
          'subject': 'Follow-up $position - [Your Name]',
          'body': 'Hi [Recruiter Name / $company Team], hope you\'re having a good week!\n\n'
              'This is [Your Name] — I recently applied for the $position role. Just wanted to check if there are any updates regarding the next steps?\n\n'
              'Thanks so much! 🙏',
        },
        {
          'categoryKey': 'Follow-up',
          'category': AppStrings.categoryFollowUp,
          'title': 'Post-Interview Status Check',
          'desc': 'Inquire about results 5-7 days after your interview session.',
          'subject': 'Checking in regarding $position interview - [Your Name]',
          'body': 'Hi [Interviewer / Recruiter Name],\n\n'
              'Thanks again for chatting with me about the $position role on [Day, Date].\n\n'
              'I really enjoyed our conversation and wanted to check in on how the selection process is moving along. Let me know if there\'s anything else you need from me at this stage.\n\n'
              'Best,\n[Your Name]',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': 'Interview Confirmation',
          'desc': 'Confirm your availability for the scheduled interview.',
          'subject': 'Interview Confirmation - $position - [Your Name]',
          'body': 'Hi [Recruiter Name / $company Team],\n\n'
              'Thanks for the invite! I\'m happy to confirm the interview for the $position position:\n\n'
              '• Date: [Day, Date]\n'
              '• Time: [Time & Timezone]\n'
              '• Link / Location: [Google Meet / Zoom / Office]\n\n'
              'Looking forward to speaking with the team.\n\n'
              'Best regards,\n[Your Name]\n[Contact Info]',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': 'Post-Interview Thank You Note',
          'desc': 'Send within 24 hours after your interview finishes.',
          'subject': 'Thank you - $position interview - [Your Name]',
          'body': 'Hi [Interviewer Name],\n\n'
              'Thank you for taking the time to speak with me today about the $position role.\n\n'
              'It was great hearing about the team\'s current focus and the upcoming challenges at $company. Our conversation made me even more excited about the opportunity.\n\n'
              'Feel free to reach out if you have any follow-up questions for me.\n\n'
              'Best,\n[Your Name]',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': 'Interview Reschedule Request',
          'desc': 'Politely request a date/time change due to a schedule clash.',
          'subject': 'Reschedule Request: $position Interview - [Your Name]',
          'body': 'Hi [Recruiter Name / Hiring Team],\n\n'
              'Thanks for setting up the interview for the $position role. Unfortunately, an unexpected conflict came up on my end ([brief reason]), and I won\'t be able to make that exact slot.\n\n'
              'Would it be possible to reschedule? I\'m available at:\n'
              '• Option 1: [Day, Date, Time]\n'
              '• Option 2: [Day, Date, Time]\n\n'
              'Really sorry for the inconvenience, and thank you for being flexible.\n\n'
              'Best,\n[Your Name]',
        },
        {
          'categoryKey': 'Interview',
          'category': AppStrings.categoryInterview,
          'title': 'Technical Test / Assignment Receipt',
          'desc': 'Acknowledge receiving the test brief and give a target turn-in date.',
          'subject': 'Received: $position Technical Assessment - [Your Name]',
          'body': 'Hi [Recruiter Name / $company Team],\n\n'
              'Got the take-home challenge for the $position role — thanks for sending it over!\n\n'
              'I\'m working on it now and expect to submit everything by [Day, Date, Time]. If any questions pop up along the way, I\'ll reach out.\n\n'
              'Thanks,\n[Your Name]',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': 'Job Offer Acceptance / Follow-up',
          'desc': 'Warm response when receiving an employment offer.',
          'subject': 'Offer Response - $position - [Your Name]',
          'body': 'Hi [Recruiter Name / HR Team],\n\n'
              'Thanks so much for extending the offer for the $position role at $company! I\'m really excited about this.\n\n'
              'I\'ve gone through the details, and [I\'d love to formally accept this offer / there are a couple of points regarding benefits and start date I\'d like to quickly talk through].\n\n'
              'Do you have a few minutes for a quick call sometime today or tomorrow?\n\n'
              'Best,\n[Your Name]',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': 'Salary & Benefits Negotiation',
          'desc': 'Polite and grounded proposal to discuss compensation.',
          'subject': 'Discussion regarding $position offer - [Your Name]',
          'body': 'Hi [Recruiter Name / HR Team],\n\n'
              'Thanks again for the offer to join $company as $position. I\'m very eager to work with the team.\n\n'
              'Taking into account the role\'s scope and current industry benchmarks for someone with my experience in [skill/domain], is there any flexibility to adjust the base salary closer to [Target Amount], or look at [specific benefit/allowance]?\n\n'
              'I\'m confident we can find an arrangement that works well for both sides.\n\n'
              'Best regards,\n[Your Name]',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': 'Decision Deadline Extension Request',
          'desc': 'Ask for a few extra days to carefully evaluate the offer.',
          'subject': 'Quick question on $position offer timeline - [Your Name]',
          'body': 'Hi [Recruiter Name / HR Team],\n\n'
              'Thank you for the offer for the $position role! I\'m genuinely thrilled about the opportunity.\n\n'
              'To make sure I\'ve reviewed the contract and benefits carefully with my family, would it be okay if I get back to you with my final decision by [Day, Date]?\n\n'
              'Really appreciate your flexibility.\n\n'
              'Best,\n[Your Name]',
        },
        {
          'categoryKey': 'Offering',
          'category': AppStrings.categoryOffering,
          'title': 'Declining an Offer Graciously',
          'desc': 'Turn down an offer respectfully without burning bridges.',
          'subject': 'Thank you regarding $position offer - [Your Name]',
          'body': 'Hi [Recruiter Name / HR Team],\n\n'
              'Thank you so much for the offer to join $company as $position. I really enjoyed getting to know you and the team throughout this process.\n\n'
              'After thinking things over, I\'ve decided to pursue another opportunity that\'s currently a closer fit for my immediate career direction.\n\n'
              'I really appreciate your time and help, and I hope our paths cross again in the future.\n\n'
              'Best regards,\n[Your Name]',
        },
      ];
    }

    return [
      {
        'categoryKey': 'Follow-up',
        'category': AppStrings.categoryFollowUp,
        'title': 'Follow-Up Status Lamaran (Email)',
        'desc': 'Tanyakan kabar jika sudah > 7 hari belum ada respons sejak melamar.',
        'subject': 'Follow-up Lamaran $position - [Nama Anda]',
        'body': 'Halo Tim Rekrutmen $company,\n\n'
            'Perkenalkan saya [Nama Anda]. Saya sebelumnya melamar untuk posisi $position di $company pada [Tanggal / minggu lalu].\n\n'
            'Saya ingin menanyakan kabar terbaru terkait proses seleksi untuk posisi ini. Saya masih sangat berminat dengan peran ini, dan jika ada berkas atau portofolio tambahan yang dibutuhkan, dengan senang hati akan saya kirimkan.\n\n'
            'Terima kasih atas waktu dan bantuannya ya.\n\n'
            'Salam,\n[Nama Anda]\n[Nomor Telepon/WhatsApp]\n[LinkedIn Profile]',
      },
      {
        'categoryKey': 'Follow-up',
        'category': AppStrings.categoryFollowUp,
        'title': 'Follow-Up Singkat via WhatsApp',
        'desc': 'Pesan santun, luwes, dan to the point untuk chat langsung ke recruiter.',
        'subject': 'Follow-up Lamaran $position - [Nama Anda]',
        'body': 'Halo kak [Nama HR / Tim Rekrutmen $company], selamat pagi/siang.\n\n'
            'Saya [Nama Anda] yang kemarin melamar untuk posisi $position. Mau tanya santai, apakah sudah ada kabar atau update terkait proses seleksinya ya kak?\n\n'
            'Terima kasih banyak kak 🙏',
      },
      {
        'categoryKey': 'Follow-up',
        'category': AppStrings.categoryFollowUp,
        'title': 'Follow-Up Hasil Wawancara / User',
        'desc': 'Tanyakan kelanjutan hasil wawancara 5-7 hari kerja setelah sesi interview.',
        'subject': 'Follow-up Hasil Interview $position - [Nama Anda]',
        'body': 'Halo Tim Rekrutmen $company / Kak [Nama HR],\n\n'
            'Menyambung sesi interview kita untuk posisi $position pada [Hari, Tanggal], saya mau follow up apakah sudah ada kabar kelanjutan hasilnya?\n\n'
            'Kemarin diskusinya seru banget dan saya semakin tertarik untuk bisa berkontribusi di tim $company. Kalau ada hal lain yang perlu dikonfirmasi, kabar-kabari saja ya kak.\n\n'
            'Terima kasih banyak,\n[Nama Anda]',
      },
      {
        'categoryKey': 'Interview',
        'category': AppStrings.categoryInterview,
        'title': 'Konfirmasi Jadwal Wawancara',
        'desc': 'Konfirmasi kesiapan hadir setelah menerima undangan interview.',
        'subject': 'Konfirmasi Kehadiran Interview $position - [Nama Anda]',
        'body': 'Halo Tim Rekrutmen $company,\n\n'
            'Terima kasih undangannya! Saya siap hadir untuk sesi interview $position sesuai jadwal:\n\n'
            '• Hari/Tanggal: [Hari, Tanggal]\n'
            '• Waktu: [Waktu WIB]\n'
            '• Media: [Google Meet / Zoom / Kantor $company]\n\n'
            'Sampai ketemu di sesi wawancara nanti ya.\n\n'
            'Salam,\n[Nama Anda]\n[Nomor Kontak]',
      },
      {
        'categoryKey': 'Interview',
        'category': AppStrings.categoryInterview,
        'title': 'Thank You Note (Setelah Interview)',
        'desc': 'Kirim dalam waktu 24 jam setelah sesi interview selesai.',
        'subject': 'Terima kasih atas diskusinya - $position - [Nama Anda]',
        'body': 'Halo Kak [Nama Pewawancara / Tim HR],\n\n'
            'Terima kasih banyak ya atas waktu dan diskusinya tadi untuk posisi $position.\n\n'
            'Senang sekali bisa ngobrol langsung dan dengar rencana tim ke depan. Obrolan tadi bikin saya semakin yakin kalau peran ini cocok dengan pengalaman saya.\n\n'
            'Kalau butuh data atau portofolio pendukung lainnya, jangan ragu kontak saya ya kak.\n\n'
            'Salam hangat,\n[Nama Anda]',
      },
      {
        'categoryKey': 'Interview',
        'category': AppStrings.categoryInterview,
        'title': 'Permohonan Reschedule Jadwal',
        'desc': 'Minta ganti jadwal dengan sopan tanpa terkesan kaku.',
        'subject': 'Permohonan Ganti Jadwal Interview $position - [Nama Anda]',
        'body': 'Halo Tim Rekrutmen $company,\n\n'
            'Terima kasih banyak undangannya untuk posisi $position. Mohon maaf sekali, di waktu yang dijadwalkan kebetulan saya ada agenda mendesak yang belum bisa digeser ([alasan singkat]).\n\n'
            'Boleh minta tolong dijadwalkan ulang? Sebagai alternatif, saya bisa di opsi waktu ini:\n'
            '• Opsi 1: [Hari, Tanggal, Jam]\n'
            '• Opsi 2: [Hari, Tanggal, Jam]\n\n'
            'Mohon maaf merepotkan dan terima kasih banyak pengertiannya ya.\n\n'
            'Salam,\n[Nama Anda]',
      },
      {
        'categoryKey': 'Interview',
        'category': AppStrings.categoryInterview,
        'title': 'Konfirmasi Pengerjaan Tes Teknis',
        'desc': 'Konfirmasi soal take-home test sudah diterima dan siap dikerjakan.',
        'subject': 'Penerimaan Soal Tes Teknis $position - [Nama Anda]',
        'body': 'Halo Tim Rekrutmen $company,\n\n'
            'Soal dan instruksi tes teknis untuk posisi $position sudah saya terima dengan baik.\n\n'
            'Saya segera mulai kerjakan dan rencananya akan saya kumpulkan paling lambat [Hari, Tanggal, Jam]. Kalau ada hal yang kurang jelas di tengah pengerjaan, nanti saya izin kontak kembali ya.\n\n'
            'Terima kasih atas kesempatannya!\n\n'
            'Salam,\n[Nama Anda]',
      },
      {
        'categoryKey': 'Offering',
        'category': AppStrings.categoryOffering,
        'title': 'Respon Tawaran Kerja (Offering Letter)',
        'desc': 'Respon positif saat menerima tawaran kerja resmi.',
        'subject': 'Respon Offering Letter $position - [Nama Anda]',
        'body': 'Halo Tim HR $company,\n\n'
            'Terima kasih banyak atas penawaran kerja (Offering Letter) untuk posisi $position di $company. Senang sekali dapat kabar baik ini!\n\n'
            'Saya sudah mempelajari rinciannya. [Saya dengan senang hati menerima penawaran ini / Ada sedikit hal terkait benefit/jadwal mulai yang ingin saya diskusikan sebentar].\n\n'
            'Kira-kira kapan waktu luang untuk ngobrol sebentar ya?\n\n'
            'Terima kasih banyak,\n[Nama Anda]',
      },
      {
        'categoryKey': 'Offering',
        'category': AppStrings.categoryOffering,
        'title': 'Diskusi Negosiasi Gaji & Benefit',
        'desc': 'Format negosiasi yang santun, profesional, dan beralasan kuat.',
        'subject': 'Diskusi Penawaran Kerja $position - [Nama Anda]',
        'body': 'Halo Tim HR $company,\n\n'
            'Terima kasih banyak atas penawaran untuk posisi $position. Saya sangat antusias untuk bisa segera bergabung dan bekerja bareng tim $company.\n\n'
            'Terkait kompensasi yang ditawarkan, melihat lingkup tanggung jawab peran ini dan ekspektasi yang sempat kita bahas, apakah masih ada ruang untuk menyesuaikan gaji pokok di kisaran [Rp X.000.000], atau fleksibilitas di benefit seperti [tunjangan/skema kerja]?\n\n'
            'Saya harap kita bisa dapat titik temu yang pas untuk kedua belah pihak. Terima kasih ya!\n\n'
            'Salam,\n[Nama Anda]',
      },
      {
        'categoryKey': 'Offering',
        'category': AppStrings.categoryOffering,
        'title': 'Permohonan Waktu Pertimbangan',
        'desc': 'Minta waktu 2-3 hari untuk menimbang tawaran dengan matang.',
        'subject': 'Pertimbangan Penawaran $position - [Nama Anda]',
        'body': 'Halo Tim HR $company,\n\n'
            'Terima kasih banyak atas penawaran kerja untuk posisi $position. Saya sangat mengapresiasi kesempatan ini.\n\n'
            'Supaya saya bisa mempelajari dokumen kontrak dan detail benefitnya dengan teliti bersama keluarga, apakah diperbolehkan jika saya memberikan konfirmasi akhir paling lambat pada [Hari, Tanggal]?\n\n'
            'Terima kasih banyak atas fleksibilitas dan pengertiannya ya.\n\n'
            'Salam,\n[Nama Anda]',
      },
      {
        'categoryKey': 'Offering',
        'category': AppStrings.categoryOffering,
        'title': 'Menolak Penawaran Secara Halus',
        'desc': 'Menolak tawaran secara santun dan tetap menjaga silaturahmi.',
        'subject': 'Terima kasih atas penawaran $position - [Nama Anda]',
        'body': 'Halo Tim HR $company,\n\n'
            'Terima kasih banyak atas penawaran kerja untuk posisi $position di $company. Senang sekali bisa mengenal tim selama proses rekrutmen ini.\n\n'
            'Setelah mempertimbangkan beberapa hal, mohon maaf saat ini saya belum bisa menerima tawaran ini karena [memutuskan mengambil kesempatan lain yang lebih cocok dengan arah karir saya saat ini / alasan personal].\n\n'
            'Terima kasih banyak atas waktu dan keramahan tim $company. Sukses selalu dan semoga kita bisa tetap terhubung ya.\n\n'
            'Salam hangat,\n[Nama Anda]',
      },
    ];
  }

  void _copyToClipboard(String text, String label) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.checkmark_circle_fill,
                color: AppColors.pastelMint, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.copiedToast(label),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.isMonochrome;
    final templates = _getTemplates();
    final categories = [
      AppStrings.categoryAll,
      AppStrings.categoryFollowUp,
      AppStrings.categoryInterview,
      AppStrings.categoryOffering,
    ];

    final rawCategories = ['All', 'Follow-up', 'Interview', 'Offering'];

    final filtered = _selectedCategoryIndex == 0
        ? templates
        : templates.where((t) =>
            t['categoryKey'] == rawCategories[_selectedCategoryIndex] ||
            t['category'] == rawCategories[_selectedCategoryIndex] ||
            t['category'] == categories[_selectedCategoryIndex]).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark: isDark, isMonochrome: isMono),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 38,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.hrTemplatesSheetTitle,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.hrTemplatesSheetSubtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    CupertinoIcons.xmark_circle_fill,
                    color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Category Pills
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = _selectedCategoryIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = idx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isMono
                              ? (isDark ? Colors.white : const Color(0xFF18181B))
                              : AppColors.pastelLime)
                          : (isMono
                              ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                              : (isDark ? AppColors.darkSurfaceVariantPastel : AppColors.lightSurfaceVariantPastel)),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      categories[idx],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? (isMono
                                ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                : AppColors.textOnPastel)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: AppColors.getBorder(isDark: isDark, isMonochrome: isMono),
          ),

          // Templates List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isMono ? const Color(0xFF27272A) : AppColors.darkSurfacePastel)
                        : (isMono ? const Color(0xFFFAFAFA) : AppColors.lightSurfaceVariantPastel),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.getBorder(isDark: isDark, isMonochrome: isMono),
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['title']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black26 : const Color(0xFFE4E4E7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['category']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['desc']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subject Preview
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black38 : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          'Subject: ${item['subject']}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFE4E4E7) : const Color(0xFF3F3F46),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Body Preview (Scrollable)
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 150),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 0.6,
                          ),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: SelectableText(
                              item['body']!,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _copyToClipboard(item['subject']!, AppStrings.copySubjectButton),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: isDark ? Colors.white : const Color(0xFF18181B),
                                side: BorderSide(
                                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                AppStrings.copySubjectButton,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : const Color(0xFF18181B),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _copyToClipboard(item['body']!, AppStrings.copyBodyButton),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isMono
                                    ? (isDark ? Colors.white : const Color(0xFF18181B))
                                    : AppColors.pastelLavender,
                                foregroundColor: isMono
                                    ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                    : const Color(0xFF09090B),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                AppStrings.copyBodyButton,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isMono
                                      ? (isDark ? const Color(0xFF18181B) : Colors.white)
                                      : const Color(0xFF09090B),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
